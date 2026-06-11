# Making it easier to add states — proposal sketch

Status: **draft for discussion** (not implemented). Code blocks are sketches, not
finished/tested code. Grounded in the current codebase and the GBH "State
customization assessment" (CO / MI / PA), which estimates each new state at
~1 new screen, ~2 new fields, ~a dozen copy changes, and 2 PDF fields.

## What already scales well (don't touch)

- `LocationData::States::STATES_INFO` + `ACTIVE_STATES` — dropdown, survey URL,
  PDF class, and office-lookup mode all key off this hash. New state = new entry.
- Office data is pure data (`config/data/counties/*.csv`), routed by `office_by`
  (`:county` vs `:zip_code`). New state = drop in a CSV.
- PDF variation swaps on `pdf_filler_class` (`screener.rb#pdf`).

The goal of this proposal is **not** "move everything into config." It's to fix
the two seams that scale badly — copy that varies only by program name, and
exemption logic that branches on `NORTH_CAROLINA` in scattered places — plus
give the one genuinely new pattern (geo-exemption / waived counties) a home.

This covers items **#1, #3, #4** from our discussion. (#2 — converting the
copy-branching helper methods to inline state-keyed i18n lookups — is on a
separate branch.)

---

## #1 — Program-name interpolation token

### Problem

The single biggest copy driver across the new states is **the program name**.
MI refers to "FAP (SNAP)" and "FIP (TANF)"; the assessment counts ~15 "text
changes" for MI, but many are the same token appearing in different screens
(homepage, age-exemption, basic-info milestone, mailer, etc.). Today "SNAP" is
hard-coded into dozens of locale strings, so a state that renames the program
means re-authoring all of them.

```
$ grep -c "SNAP" config/locales/en.yml      # dozens of occurrences
```

### Sketch

1. Add the program name(s) to the per-state config:

```ruby
# app/models/location_data.rb
STATES_INFO = {
  NORTH_CAROLINA => { display_name: "North Carolina", program_name: "SNAP",
                      program_acronym: "SNAP", tanf_name: "TANF", ... },
  # a future MI entry:
  # MICHIGAN     => { display_name: "Michigan", program_name: "FAP (SNAP)",
  #                   program_acronym: "FAP", tanf_name: "FIP (TANF)", ... },
}
```

2. Make those variables available to **every** `t(...)` call by merging them into
   the interpolation options. Rails i18n ignores interpolation variables a string
   doesn't use, so injecting `program_name` everywhere is safe even for strings
   that don't reference it. (It only raises on a `%{var}` with *no* value.)

```ruby
# app/helpers/application_helper.rb  (mirror the same override in
# ApplicationController so controller-side I18n.t / t also get the vars)
module ApplicationHelper
  def translate(key, **options)
    super(key, **state_interpolations.merge(options))
  end
  alias_method :t, :translate

  def state_interpolations
    info = LocationData::States::STATES_INFO[current_screener&.state]
    return {} unless info
    { program_name: info[:program_name],
      program_acronym: info[:program_acronym],
      tanf_name: info[:tanf_name] }
  end
end
```

3. Rewrite shared copy to interpolate instead of hard-coding "SNAP":

```yaml
# before
title_html: Based on your answers, you do <u>not</u> have to follow the SNAP work rules.
# after
title_html: Based on your answers, you do <u>not</u> have to follow the %{program_name} work rules.
```

### After this, adding a state's program name = **one config value**.

The bulk migration (replace literal "SNAP" → `%{program_name}` in shared strings)
is a mechanical one-time sweep. Strings that are genuinely state-specific (not
just the program name) still live under state-keyed i18n keys (see #2).

### Open questions / tradeoffs

- Overriding `t` is global and slightly magic. Alternative: vita-min's explicit
  style — pass `program_name:` to each `t` call. Less magic, much more verbose
  given how many call sites use "SNAP". Recommendation: the override.
- Need to confirm i18n's `raise` behavior in our config (we want extra/unused
  interpolation vars to be ignored, which is the default).
- Possessive/grammatical forms ("SNAP agency", "SNAP benefits") all interpolate
  fine; no pluralization concerns for the program name itself.

---

## #3 — State policy object (consolidate the scattered NC branches)

### Problem

The *logic* (not copy) that varies by state is spread across `Screener`:

| Location | Branch |
| --- | --- |
| `screener.rb#exempt_from_state_work_rules?` (~282) | `case state when NORTH_CAROLINA` → delegate to `nc_screener` |
| `screener.rb#american_indian_exemption_requires_proof?` (~295) | NC returns false |
| `screener.rb#needs_proof_of_volunteering?` (~445) | `state != NORTH_CAROLINA && volunteering?` |
| `screener.rb#any_preventing_work?` (~259) | reaches into `nc_screener` |

Adding a state means finding all of these. A per-state policy object gives each
state one home.

### Sketch

```ruby
# app/models/state_policy.rb  (plain domain object; stays in app/models)
module StatePolicy
  def self.for(screener)
    klass = LocationData::States::STATES_INFO.dig(screener.state, :policy_class) || Base
    klass.new(screener)
  end

  class Base
    def initialize(screener) = @screener = screener
    attr_reader :screener

    def exempt_from_state_work_rules? = false
    def american_indian_exemption_requires_proof? = screener.is_american_indian_yes?
    def needs_proof_of_volunteering? = screener.volunteering?
    def extra_preventing_work? = false
    def geographically_exempt? = false   # see #4
  end

  class NorthCarolina < Base
    def exempt_from_state_work_rules?
      screener.nc_screener.present? && screener.nc_screener.exempt_from_work_rules?
    end

    def american_indian_exemption_requires_proof? = false
    def needs_proof_of_volunteering? = false

    def extra_preventing_work?
      screener.nc_screener.present? &&
        screener.nc_screener.age_work_education_health_exemption?
    end
  end

  class Delaware < Base
  end
end
```

```ruby
# app/models/location_data.rb — STATES_INFO entries gain:
#   policy_class: StatePolicy::NorthCarolina   (and StatePolicy::Delaware)

# app/models/screener.rb
def state_policy
  StatePolicy.for(self)
end
delegate :exempt_from_state_work_rules?,
         :american_indian_exemption_requires_proof?,
         :needs_proof_of_volunteering?,
         :geographically_exempt?,
         to: :state_policy
```

`any_preventing_work?` becomes:

```ruby
def any_preventing_work?
  PREVENTING_WORK_ATTRIBUTES.any? { |attr| public_send("#{attr}_yes?") } ||
    state_policy.extra_preventing_work?
end
```

### After this, "what's different about this state's rules" lives in **one class**.

Adding a state = add a `StatePolicy::Xyz < Base` (often nearly empty, like
Delaware) and point `policy_class:` at it. No edits scattered through `Screener`.

### Open questions / tradeoffs

- `STATES_INFO` already references autoloaded classes (`PdfFiller::*`), so
  referencing `StatePolicy::*` there is consistent — but worth confirming load
  order.
- Where to draw the line: keep `Screener` as the data/record, move per-state
  *decisions* into the policy. Some methods (e.g. office lookup) are arguably
  already config-driven via `office_by` and can stay.

---

## #4 — Geo-exemption seam (waived counties/cities) + generic state-data

### Problem (the one genuinely new pattern)

CO and MI waive some counties/cities from the work rules entirely. MI also adds a
conditional "do you live in [waived city]?" follow-up. NC/DE have no equivalent.
This is the new screen + new field for those states. It fits cleanly on top of #3.

### Sketch — waived areas are data, mirroring `is_supported`

`OutOfStateController` already reads an `Is Supported?` CSV column. Add an
`Is Waived?` column the same way:

```ruby
# app/models/location_data.rb (Counties.load_all / ZipCodes.load_all)
is_waived: row["Is Waived?"] == "Y",
```

```ruby
# StatePolicy for a future Michigan
class Michigan < Base
  def geographically_exempt?
    county = LocationData::Counties.for_state(screener.state)[screener.county]
    county&.dig(:is_waived) || waived_city?
  end

  private

  def waived_city?
    screener.lives_in_waived_city_yes?   # new field, set by the follow-up question
  end
end
```

The early-exit screen is one shared controller (reused by CO and MI):

```ruby
# app/controllers/geo_exemption_controller.rb
class GeoExemptionController < QuestionController
  def show_progress_bar = false
  def self.show?(screener) = screener.geographically_exempt?
end
```

Inserted into `Navigation::ScreenerNavigation::FLOW` right after the location
steps. The "do you live in [waived city]?" follow-up is the same shape as the
existing `Nc::HomeschoolController` conditional sub-question.

### Generic state-data seam (replace the `nc_screener` branch)

Today `LocationController#after_update_success` hard-codes NC:

```ruby
if current_screener.state == NORTH_CAROLINA && current_screener.nc_screener.nil?
  current_screener.create_nc_screener
end
```

Generalize the *seam* (not the storage — keep typed per-state models like
`NcScreener`; they're clearer than a JSON bag for a handful of fields):

```ruby
# StatePolicy::Base
def ensure_state_data! = nil          # default: nothing
# StatePolicy::NorthCarolina
def ensure_state_data!
  screener.create_nc_screener if screener.nc_screener.nil?
end

# LocationController#after_update_success
current_screener.state_policy.ensure_state_data!
```

### After this, a waived-county state = CSV column + a `geographically_exempt?` in its policy + reuse the shared screen.

### Open questions / tradeoffs

- MI's waived-city follow-up needs a real field + a small controller; sketch
  above assumes a `lives_in_waived_city` enum on `Screener` (or on state-data).
- "Routing info needed for larger counties" (from the assessment) may need more
  than `is_waived` — flag as a separate spike.
- Keep per-state models (`NcScreener`, future `MiScreener`) — only the *seam*
  through `Screener` becomes generic, via `state_policy`.

---

## Suggested sequencing

1. **#1 program-name token** — highest effort reduction, content-owned, low risk.
   Worth doing even before the next state.
2. **#3 state policy object** — the durable structural win; also where #4 hangs.
3. **#4 geo-exemption seam** — demand-driven; do it when we actually commit to
   CO/MI.

(#2, the i18n copy lookup, is independent and can land anytime.)

## Things this proposal deliberately does NOT do

- No data-driven flow/visibility engine. With ~1 new screen per state, `show?`
  as code is fine.
- No generic JSON "state answers" bag. Typed per-state models are clearer.
- No change to the office-data CSV / PDF-class config — those already scale.

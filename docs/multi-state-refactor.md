# Multi-State Refactor

## The two distinct problems

**1. State-specific logic** — which questions show, what copy appears, which PDF to use — scattered across controllers, views, and navigation.

**2. State-specific data** — `NcScreener` as a separate model, tightly coupled to one state when its fields may be reusable.

---

## For the logic: State strategy objects

Create a strategy class per state that becomes the single place to put state-specific behaviour:

```ruby
module StateStrategy
  class Base
    def time_limit_text; raise NotImplementedError; end
    def pdf_source(screener); raise NotImplementedError; end
    # any other state-varying behaviour
  end

  class NorthCarolina < Base
    def time_limit_text
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_nc")
    end
  end

  class Delaware < Base
    def time_limit_text
      I18n.t("views.work_rules_apply_unmet.edit.time_limit_text_default")
    end
  end
end
```

`Screener` (or a helper) resolves the right strategy:

```ruby
def state_strategy
  StateStrategy.const_get(state_name_as_class) rescue StateStrategy::Base
end
```

Controllers and views then call `screener.state_strategy.time_limit_text` instead of branching on `state ==`. Adding a new state means adding one new class.

---

## For navigation: Per-state navigation class

`screener_navigation.rb` likely already branches on state. Rather than one navigation class with state conditionals, each state gets its own:

```ruby
class Navigation::NorthCarolinaNavigation < Navigation::BaseNavigation
  def steps
    [...NC specific steps...]
  end
end
```

`ApplicationController#navigation_class` then resolves based on the screener's state rather than always returning the same class.

---

## For the database: Generalise `NcScreener`

The current `has_one :nc_screener` couples extra fields permanently to NC. Two options:

**Option A — Fold into `Screener` directly**
If the fields are few and likely shared (education history, work history), just add them to `Screener` with `null: true`. Simple, no join needed.

**Option B — Generic `ScreenerSupplementalData` table**
If the extra fields grow significantly per state:

```
screener_supplemental_data
  screener_id
  state          (discriminator)
  field_name
  value
```

Or a more structured version with a `type` column for STI:

```
state_screeners
  screener_id
  type           # "NcStateScreener", "NewStateScreener"
  ...shared columns
```

This lets NC and any future state share the same extension table without creating a new model per state.

---

## Migration path

Rather than doing this all at once, the natural order would be:

1. **Extract state strategy objects** first — purely a code move, no database change, immediately removes scattered `state ==` checks
2. **Generalise navigation** — refactor `screener_navigation.rb` into per-state classes
3. **Database change last** — migrate `nc_screener` fields to the generalised structure once you know which fields a second state actually needs

The strategy object refactor gives you the most immediate payoff with the least risk since it doesn't touch the database or navigation routing at all.

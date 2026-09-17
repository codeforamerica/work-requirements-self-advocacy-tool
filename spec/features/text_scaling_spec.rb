require "rails_helper"

# WRSAT-754: a participant with an increased phone font size saw text and buttons
# spill out of the layout. These specs walk the flow at 200% text and fail if any
# page scrolls sideways, so the whole class of bug stays fixed rather than just
# the one page it was reported on. Run with OVERFLOW_DEBUG=1 to see the layout
# chain above each offending element.
RSpec.feature "Screener flow at 200% text", js: true, driver: :selenium_chrome_headless_large_text do
  include TextScaling
  include TextScaling::AuditsEachPageBeforeClick

  def start_at_200_percent_text(viewport)
    # visit before emulating, so the metrics override binds to the target the
    # walk actually uses -- see TextScaling#emulate_viewport
    visit root_path
    emulate_viewport(viewport)
    expect_text_to_be_scaled_up
  end

  # The last page of a walk is never followed by a click, so it needs checking
  # explicitly before the run is reported.
  def finish_audit!
    audit_current_page
    report_text_scaling_offenses!
  end

  def walk_de_flow
    step_homepage
    step_de_location
    step_date_of_birth(year: "1965")
    step_exemption_questions(caring: :disabled_or_ill)
    step_school_enrollment(answer: :yes)
    step_alcohol_treatment_program(answer: :yes, program_name: "Pro Gram")
    step_prevention_section(situations: [:medical_condition, :other], details: "Some things are best left unwritten.")
    step_personal_info_section(
      first_name: "Prue", last_name: "Leith",
      phone: "415-816-1286", email: ScreenerSteps::EMAIL, ssn: "1234",
      check_phone_toggle: true
    )
    step_signature_and_download(signature: "Prudence Leith", email: ScreenerSteps::EMAIL)
  end

  {
    # 390px is where the bug was reported: the narrowest common phone, where the
    # gutters and the text are competing for the least room.
    "on a phone" => TextScaling::PHONE_VIEWPORT,
    # past the 800px breakpoint the card takes on much roomier padding, which at
    # 200% text can squeeze the content column harder than the phone layout does
    "above the 800px breakpoint" => TextScaling::DESKTOP_VIEWPORT
  }.each do |where, viewport|
    scenario "reflows #{where} without horizontal scrolling" do
      start_at_200_percent_text(viewport)

      # The SSN field pairs a "### - ## -" mask with a four-digit input inside a
      # CSS table that cannot shrink below the mask, so at 200% text the input
      # was left 50px to show digits needing 101px. That fits the viewport, so
      # the overflow check cannot see it -- assert the field stays readable.
      check_on_path("/basic-info-ssn") { expect_field_to_show("input.ssn-last4", "0000") }

      walk_de_flow

      finish_audit!
    end
  end

  # The NC flow is the DE flow plus two extra pages, and three shared pages whose
  # content is state-specific. Walking it is unavoidable -- the flow will not let
  # you jump to /homeschool -- but only those five pages are checked, since the
  # phone scenario above already covers the twenty they have in common.
  scenario "reflows on the NC-specific pages without horizontal scrolling" do
    start_at_200_percent_text(TextScaling::PHONE_VIEWPORT)
    only_check_paths(
      "/location",          # NC asks for a county as well as a state
      "/homeschool",        # NC only
      "/edu-work-history",  # NC only
      "/signature",         # lists NC's state-specific exemption reasons
      "/download-form"      # names NC's agency and county office addresses
    )

    step_homepage
    step_nc_location
    step_date_of_birth(year: "1965")
    step_exemption_questions(caring: :disabled_or_ill)
    step_nc_homeschool(enrolled: true)
    step_school_enrollment(answer: :yes)
    step_nc_edu_work_history
    step_alcohol_treatment_program(answer: :yes, program_name: "Pro Gram")
    step_prevention_section(situations: [:place_to_sleep, :other], details: "Some things are best left unwritten.")
    step_personal_info_section(
      first_name: "Prue", last_name: "Leith",
      phone: "415-816-1286", email: ScreenerSteps::EMAIL, ssn: "1234",
      check_phone_toggle: true
    )
    step_signature_and_download(signature: "Prudence Leith", email: ScreenerSteps::EMAIL)

    finish_audit!
  end
end

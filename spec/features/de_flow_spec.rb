require "rails_helper"

RSpec.feature "DE Screener flow", js: true do
  scenario "client with regular exemption" do
    step_homepage
    step_de_location

    step_date_of_birth(year: "1965")
    step_exemption_questions(caring: :disabled_or_ill)
    step_school_enrollment(answer: :yes)
    step_alcohol_treatment_program(answer: :yes, program_name: "Pro Gram")
    step_prevention_section(situations: [:medical_condition, :other], details: "Some things are best left unwritten.")
    step_personal_info_section(
      first_name: "Prue", last_name: "Leith",
      phone: "415-816-1286", email: EMAIL, ssn: "1234",
      check_phone_toggle: true
    )
    step_signature_and_download(signature: "Prudence Leith", email: EMAIL, with_back_nav: true)
    step_feedback_section
  end

  scenario "client with earnings exemption" do
    step_homepage
    step_de_location

    step_date_of_birth(year: "1990")
    step_exemption_questions(caring: :none)
    step_school_enrollment(answer: :no)
    step_alcohol_treatment_program(answer: :no)
    step_prevention_section(situations: :none)
    step_work_activity_section(hours: 35, earnings: 300.40)
    step_personal_info_section(
      first_name: "Mary", last_name: "Berry",
      phone: "415-816-1286", email: EMAIL, ssn: "1234"
    )
    step_signature_and_download(signature: "Mary Berry", email: EMAIL, check_earnings_exemption: true)

    screener = Screener.order(:created_at).last
    expect(screener.is_working_yes?).to eq true
    expect(screener.working_hours).to eq 35
    expect(screener.working_weekly_earnings).to eq 300.40
    expect(screener.has_earnings_exemption?).to eq true
    expect(screener.has_exemption?).to eq false
  end
end

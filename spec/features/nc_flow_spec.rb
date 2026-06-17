require "rails_helper"

RSpec.feature "NC Screener flow", js: true do
  scenario "client with regular exemption" do
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
    step_signature_and_download(signature: "Prudence Leith", email: ScreenerSteps::EMAIL, with_back_nav: true)
    step_feedback_section
  end

  scenario "client with earnings exemption" do
    step_homepage
    step_nc_location

    step_date_of_birth(year: "1990")
    step_exemption_questions(caring: :none)
    step_nc_homeschool(enrolled: false)
    step_school_enrollment(answer: :no)
    step_alcohol_treatment_program(answer: :no)
    step_prevention_section(situations: :none)
    step_work_activity_section(hours: 35, earnings: 300.40)
    step_personal_info_section(
      first_name: "Mary", last_name: "Berry",
      phone: "415-816-1286", email: ScreenerSteps::EMAIL, ssn: "1234"
    )
    step_signature_and_download(signature: "Mary Berry", email: ScreenerSteps::EMAIL, check_earnings_exemption: true)

    screener = Screener.order(:created_at).last
    expect(screener.is_working_yes?).to eq true
    expect(screener.working_hours).to eq 35
    expect(screener.working_weekly_earnings).to eq 300.40
    expect(screener.has_earnings_exemption?).to eq true
    expect(screener.has_exemption?).to eq false
  end

  scenario "client with age 65+ exemption" do
    step_homepage
    step_nc_location

    step_date_of_birth(year: "1945")

    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.age_exemption.edit.title_html")))
  end

  scenario "client with age <18 exemption" do
    step_homepage
    step_nc_location

    step_date_of_birth(year: "2025")

    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.age_exemption.edit.title_html")))
  end

  private

  def step_nc_location
    select "North Carolina", from: "screener_state"
    select "Durham County", from: "screener_county"
    click_on I18n.t("general.continue")
  end

  def step_nc_homeschool(enrolled:, name: "Tough Nuts Academy", hours: "25")
    expect(page).to have_selector("h1", text: I18n.t("views.nc.homeschool.edit.title"))
    if enrolled
      choose I18n.t("general.affirmative")
      fill_in I18n.t("views.nc.homeschool.edit.homeschool_name_label"), with: name
      fill_in I18n.t("views.nc.homeschool.edit.homeschool_hours_label"), with: hours
    else
      choose I18n.t("general.negative")
    end
    click_on I18n.t("general.continue")
  end

  def step_nc_edu_work_history
    expect(page).to have_selector("h1", text: I18n.t("views.nc.edu_work_history.edit.title"))
    within(".question-with-follow-up__question") do
      choose I18n.t("general.negative")
    end
    within("#worked-last-five-years") do
      choose I18n.t("general.affirmative")
    end
    click_on I18n.t("general.continue")
  end
end

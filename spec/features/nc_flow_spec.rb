require "rails_helper"

EMAIL = "hi@example.com"

RSpec.feature "NC Screener flow", js: true do
  scenario "client with regular exemption" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.homepage.index.title"))
    click_on I18n.t("views.homepage.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
    select "North Carolina", from: "screener_state"
    select "Durham County", from: "screener_county"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "1965", from: "Year"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.tribe_or_nation.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.living_with_someone.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.caring_for_someone.edit.title"))
    check I18n.t("views.caring_for_someone.edit.disabled_or_ill_person")
    fill_in(I18n.t("views.caring_for_someone.edit.additional_care_info"), with: "lots of care")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.pregnancy.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.unemployment.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.disability_benefits.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.migrant_farmworker.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.nc.homeschool.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.nc.homeschool.edit.homeschool_name_label"), with: "Tough Nuts Academy"
    fill_in I18n.t("views.nc.homeschool.edit.homeschool_hours_label"), with: "25"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.school_enrollment.edit.title"))
    choose I18n.t("general.affirmative")
    choose I18n.t("views.school_enrollment.edit.school_type_college_or_trade_school")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.nc.edu_work_history.edit.title"))
    within(".question-with-follow-up__question") do
      choose I18n.t("general.negative")
    end
    within("#worked-last-five-years") do
      choose I18n.t("general.affirmative")
    end
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.alcohol_treatment_program.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.alcohol_treatment_program.edit.alcohol_treatment_program_name_label"), with: "Pro Gram"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_situations.edit.title"))
    check I18n.t("views.preventing_work_situations.edit.preventing_work_place_to_sleep")
    check I18n.t("views.preventing_work_situations.edit.other")
    fill_in I18n.t("views.preventing_work_situations.edit.preventing_work_write_in"), with: "my spoon carving side hustle"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_details.edit.title"))
    fill_in "preventing_work_additional_info", with: "Some things are best left unwritten."
    click_on I18n.t("general.continue")

    # The screener has an exemption, so every work/volunteer/training pages are skipped
    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.basic_info_milestone.edit.title_html")))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_details.edit.title"))
    fill_in I18n.t("views.basic_info_details.edit.first_name_label"), with: "Prue"
    fill_in I18n.t("views.basic_info_details.edit.last_name_label"), with: "Leith"

    expect(page).to_not have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
    fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: "415-816"
    expect(page).to_not have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
    fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: "415-816-1286"
    expect(page).to have_selector("legend", text: I18n.t("views.basic_info_details.edit.consented_to_texts.label"))
    choose I18n.t("views.basic_info_details.edit.consented_to_texts.affirmative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))

    # Check that cut & paste is disabled for email fields
    email_field = find_field(I18n.t("views.email.edit.email"))
    expect(email_field[:oncopy]).to eq "return false;"
    confirmation_field = find_field(I18n.t("views.email.edit.email_confirmation"))
    expect(confirmation_field[:onpaste]).to eq "return false;"

    fill_in I18n.t("views.email.edit.email"), with: EMAIL
    fill_in I18n.t("views.email.edit.email_confirmation"), with: EMAIL
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_case_number.edit.title"))
    click_on I18n.t("general.continue_without_this_number")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_ssn.edit.title"))
    fill_in I18n.t("views.basic_info_ssn.edit.ssn_label"), with: "1234"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    fill_in I18n.t("views.signature.edit.signature_label"), with: "Prudence Leith"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.download_form.edit.title_sent", email: EMAIL))
    click_on I18n.t("general.back")

    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    click_on I18n.t("general.back")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_ssn.edit.title"))
    click_on I18n.t("general.back")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_case_number.edit.title"))
    fill_in I18n.t("views.basic_info_case_number.edit.case_number_label"), with: "ABC-123"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.download_form.edit.title_sent", email: EMAIL))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.proof_guidance.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.new_response.edit.title"))
    click_on I18n.t("general.check_work_rules_for_someone_else")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
  end

  scenario "client with earnings exemption" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.homepage.index.title"))
    click_on I18n.t("views.homepage.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
    select "North Carolina", from: "screener_state"
    select "Durham County", from: "screener_county"
    click_on I18n.t("general.continue")

    # Adult under 55
    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "1990", from: "Year"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.tribe_or_nation.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.living_with_someone.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.caring_for_someone.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.pregnancy.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.unemployment.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.disability_benefits.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.migrant_farmworker.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.nc.homeschool.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.school_enrollment.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.alcohol_treatment_program.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work_situations.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    # No regular exemption: work, community service, and training program pages show
    expect(page).to have_selector("h1", text: I18n.t("views.wages_hours_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.employment.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.employment.edit.working_hours_label"), with: 35
    fill_in I18n.t("views.employment.edit.working_weekly_earnings_label"), with: 300.40
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.community_service.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.training_program.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.basic_info_milestone.edit.title_html")))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_details.edit.title"))
    fill_in I18n.t("views.basic_info_details.edit.first_name_label"), with: "Mary"
    fill_in I18n.t("views.basic_info_details.edit.last_name_label"), with: "Berry"
    fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: "415-816-1286"
    choose I18n.t("views.basic_info_details.edit.consented_to_texts.affirmative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))
    fill_in I18n.t("views.email.edit.email"), with: EMAIL
    fill_in I18n.t("views.email.edit.email_confirmation"), with: EMAIL
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_case_number.edit.title"))
    click_on I18n.t("general.continue_without_this_number")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_ssn.edit.title"))
    fill_in I18n.t("views.basic_info_ssn.edit.ssn_label"), with: "1234"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.signature.edit.title"))
    # shows earnings exemption
    expect(page).to have_content(I18n.t("views.signature.edit.exemption_working_30_hours"))
    fill_in I18n.t("views.signature.edit.signature_label"), with: "Mary Berry"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.download_form.edit.title_sent", email: EMAIL))

    screener = Screener.order(:created_at).last
    expect(screener.is_working_yes?).to eq true
    expect(screener.working_hours).to eq 35
    expect(screener.working_weekly_earnings).to eq 300.40
    expect(screener.has_earnings_exemption?).to eq true
    expect(screener.has_exemption?).to eq false
  end

  scenario "client with age 65+ exemption" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.homepage.index.title"))
    click_on I18n.t("views.homepage.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
    select "North Carolina", from: "screener_state"
    select "Durham County", from: "screener_county"
    click_on I18n.t("general.continue")

    # Adult over 65
    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "1945", from: "Year"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.age_exemption.edit.title_html")))
  end

  scenario "client with age <18 exemption" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.homepage.index.title"))
    click_on I18n.t("views.homepage.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.location.edit.title"))
    select "North Carolina", from: "screener_state"
    select "Durham County", from: "screener_county"
    click_on I18n.t("general.continue")

    # Applicant under 18
    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "2025", from: "Year"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: ActionView::Base.full_sanitizer.sanitize(I18n.t("views.age_exemption.edit.title_html")))
  end
end

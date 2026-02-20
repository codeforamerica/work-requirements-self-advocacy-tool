require "rails_helper"

RSpec.feature "Screener flow" do
  scenario "new client fills out the screener" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.landing_page.index.title"))
    click_on I18n.t("views.landing_page.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "1940", from: "Year"
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

    expect(page).to have_selector("h1", text: I18n.t("views.employment.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.employment.edit.working_hours_label"), with: 15
    fill_in I18n.t("views.employment.edit.working_weekly_earnings_label"), with: 250.35
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.migrant_farmworker.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.community_service.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.community_service.edit.volunteering_hours_label"), with: "1"
    fill_in I18n.t("views.community_service.edit.volunteering_org_label"), with: "Code for America"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.training_program.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.training_program.edit.work_training_hours_label"), with: "20"
    fill_in I18n.t("views.training_program.edit.work_training_name_label"), with: "The Great British Work Off"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.school_enrollment.edit.title"))
    click_on I18n.t("general.affirmative")

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

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_details.edit.title"))
    fill_in I18n.t("views.basic_info_details.edit.first_name_label"), with: "Prue"
    fill_in I18n.t("views.basic_info_details.edit.last_name_label"), with: "Leith"
    fill_in I18n.t("views.basic_info_details.edit.phone_number_label"), with: "415-816-1286"
    choose I18n.t("views.basic_info_details.edit.consented_to_texts.affirmative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))
    fill_in I18n.t("views.email.edit.email"), with: "hi@example.com"
    fill_in I18n.t("views.email.edit.email_confirmation"), with: "hi@example.com"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.new_response.edit.title"))
    click_on I18n.t("views.new_response.edit.check_work_rules_for_someone_else")

    expect(page).to have_selector("h1", text: I18n.t("views.date_of_birth.edit.title"))
  end
end

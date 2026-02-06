require "rails_helper"

RSpec.feature "Screener flow" do
  scenario "new client fills out the screener" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.landing_page.index.title"))
    click_on I18n.t("views.landing_page.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.birth_date.edit.title"))
    select "September", from: "Month"
    select "21", from: "Day"
    select "1940", from: "Year"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.america_indian.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.has_child.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.caring_for_someone.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.is_pregnant.edit.title"))
    choose I18n.t("general.negative")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.has_unemployment_benefits.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.disability_benefits.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.working.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.working.edit.working_hours_label"), with: 15
    fill_in I18n.t("views.working.edit.working_weekly_earnings_label"), with: 250.35
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.migrant_farmworker.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.community_service.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.community_service.edit.volunteering_hours_label"), with: "1"
    fill_in I18n.t("views.community_service.edit.volunteering_org_label"), with: "Code for America"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.work_training.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.work_training.edit.work_training_hours_label"), with: "20"
    fill_in I18n.t("views.work_training.edit.work_training_name_label"), with: "The Great British Work Off"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.is_student.edit.title"))
    click_on I18n.t("general.affirmative")

    expect(page).to have_selector("h1", text: I18n.t("views.alcohol_treatment_program.edit.title"))
    choose I18n.t("general.affirmative")
    fill_in I18n.t("views.alcohol_treatment_program.edit.alcohol_treatment_program_name_label"), with: "Pro Gram"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.personal_situations_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.preventing_work.edit.title"))
    check I18n.t("views.preventing_work.edit.preventing_work_place_to_sleep")
    check I18n.t("views.preventing_work.edit.other")
    fill_in I18n.t("views.preventing_work.edit.preventing_work_write_in"), with: "my spoon carving side hustle"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.personal_information.edit.title"))
    fill_in I18n.t("views.personal_information.edit.first_name_label"), with: "Prue"
    fill_in I18n.t("views.personal_information.edit.last_name_label"), with: "Leith"
    fill_in I18n.t("views.personal_information.edit.phone_number_label"), with: "415-816-1286"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))
    fill_in I18n.t("views.email.edit.email"), with: "hi@example.com"
    fill_in I18n.t("views.email.edit.email_confirmation"), with: "hi@example.com"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.new_response.edit.title"))
    click_on I18n.t("views.new_response.edit.check_work_rules_for_someone_else")

    expect(page).to have_selector("h1", text: I18n.t("views.birth_date.edit.title"))
  end
end

require "rails_helper"

RSpec.feature "Screener flow" do
  scenario "new client fills out the screener" do
    visit root_path

    expect(page).to have_selector("h1", text: I18n.t("views.landing_page.index.title"))
    click_on I18n.t("views.landing_page.fill_out_form")

    expect(page).to have_selector("h1", text: I18n.t("views.overview.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.language_preference.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.receiving_benefits.edit.title"))
    choose I18n.t("views.receiving_benefits.edit.is_yes")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.america_indian.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.has_child.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.caring_for_someone.edit.title"))
    check I18n.t("general.none_of_the_above")
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.has_unemployment_benefits.edit.title"))
    click_on I18n.t("general.negative")

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.personal_information.edit.title"))
    fill_in I18n.t("views.personal_information.edit.first_name_label"), with: "Prue"
    fill_in I18n.t("views.personal_information.edit.last_name_label"), with: "Leith"
    select "September", from: "Month"
    select "21", from: "Day"
    select "1940", from: "Year"
    fill_in I18n.t("views.personal_information.edit.phone_number_label"), with: "415-816-1286"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.email.edit.title"))
    fill_in I18n.t("views.email.edit.email"), with: "hi@example.com"
    fill_in I18n.t("views.email.edit.email_confirmation"), with: "hi@example.com"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h2", text: "End of example")
  end
end

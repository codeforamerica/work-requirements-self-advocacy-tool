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

    expect(page).to have_selector("h1", text: I18n.t("views.basic_info_milestone.edit.title"))
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: I18n.t("views.personal_information.edit.title"))
    fill_in I18n.t("views.personal_information.edit.first_name_label"), with: "Prue"
    fill_in I18n.t("views.personal_information.edit.last_name_label"), with: "Leith"
    click_on I18n.t("general.continue")

    expect(page).to have_selector("h1", text: "End of example")
  end
end

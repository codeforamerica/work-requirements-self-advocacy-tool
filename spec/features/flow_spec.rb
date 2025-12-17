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
  end
end

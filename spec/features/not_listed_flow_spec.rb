require "rails_helper"

RSpec.feature "Not Listed Screener flow", js: true do
  scenario "client who selects 'It's not listed here'" do
    step_homepage
    step_not_listed_location

    expect(page).to have_selector("h1", text: I18n.t("views.out_of_state.edit.title"))
    expect(page).to have_link(I18n.t("views.out_of_state.edit.find_button"))
    expect(page).not_to have_content(I18n.t("views.out_of_state.edit.contact_title"))
  end

  private

  def step_not_listed_location
    select I18n.t("views.location.edit.not_listed"), from: "screener_state"
    click_on I18n.t("general.continue")
  end
end

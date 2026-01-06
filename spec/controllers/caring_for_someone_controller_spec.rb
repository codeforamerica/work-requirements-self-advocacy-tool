require "rails_helper"

RSpec.describe CaringForSomeoneController, type: :controller do
  describe "#edit" do
    render_views

    it "maps correct value onto none of the above checkbox" do
      create(:screener, caring_for_no_one: "yes")
      get :edit

      expect(response.body).to have_checked_field(I18n.t("general.none_of_the_above"))
    end
  end

  describe "#update" do
    it "saves correct value from none of the above checkbox" do
      screener = create(:screener)

      params = {
        caring_for_child_under_6: "no",
        caring_for_disabled_or_ill_person: "no",
        none: "1"
      }

      post :update, params: { screener: params }
      expect(screener.reload.caring_for_no_one_yes?).to eq true
    end
  end
end

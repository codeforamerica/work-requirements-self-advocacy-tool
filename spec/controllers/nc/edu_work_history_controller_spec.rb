require "rails_helper"

RSpec.describe Nc::EduWorkHistoryController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "persists the values to the nc_screener" do
      screener = create(:screener, state: "NC")
      screener.create_nc_screener
      sign_in screener

      params = {
        has_hs_diploma: "no",
        worked_last_five_years: "yes"
      }

      post :update, params: {nc_screener: params}
      screener.nc_screener.reload
      expect(screener.nc_screener.has_hs_diploma).to eq "no"
      expect(screener.nc_screener.worked_last_five_years).to eq "yes"
    end
  end
end

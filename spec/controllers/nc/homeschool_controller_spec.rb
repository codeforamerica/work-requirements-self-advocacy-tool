require "rails_helper"

RSpec.describe Nc::HomeschoolController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it_behaves_like "rejects invalid enum values",
      fields: [:teaches_homeschool],
      params_key: :nc_screener,
      screener_factory: -> {
        s = create(:screener, state: "NC")
        s.create_nc_screener
        s
      }

    it_behaves_like "a controller where update fires a page_submit Mixpanel event", {nc_screener: true} do
      let(:page_submit_cases) do
        params = {teaches_homeschool: "yes", homeschool_name: "Tough Nuts Academy", homeschool_hours: "25"}
        [{form_params: params, expected_data: params}]
      end
      let(:invalid_params) { {teaches_homeschool: "yes", homeschool_name: "Academy", homeschool_hours: "not a number"} }
    end

    it "persists the values to the nc_screener" do
      screener = create(:screener, state: "NC")
      screener.create_nc_screener
      sign_in screener

      params = {
        teaches_homeschool: "yes",
        homeschool_name: "Tough Nuts Academy",
        homeschool_hours: "25"
      }

      post :update, params: {nc_screener: params}
      screener.nc_screener.reload
      expect(screener.nc_screener.teaches_homeschool).to eq "yes"
      expect(screener.nc_screener.homeschool_name).to eq "Tough Nuts Academy"
      expect(screener.nc_screener.homeschool_hours).to eq 25
    end
  end
end

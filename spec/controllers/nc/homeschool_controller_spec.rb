require "rails_helper"

RSpec.describe Nc::HomeschoolController, type: :controller do
  describe "#update" do
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

require "rails_helper"

RSpec.describe NcScreener, type: :model do
  describe "before_save" do
    it "clears worked_last_five_years if has_hs_diploma is yes" do
      screener = Screener.create(state: "NC")
      nc_screener = NcScreener.create(screener: screener, has_hs_diploma: "no", worked_last_five_years: "yes")

      nc_screener.update(has_hs_diploma: "yes")

      expect(nc_screener.reload.worked_last_five_years).to eq "unfilled"
    end

    it "preserves worked_last_five_years if has_hs_diploma is no" do
      screener = Screener.create(state: "NC")
      nc_screener = NcScreener.create(screener: screener, has_hs_diploma: "no", worked_last_five_years: "yes")

      nc_screener.update(has_hs_diploma: "no")

      expect(nc_screener.reload.worked_last_five_years).to eq "yes"
    end
  end
end

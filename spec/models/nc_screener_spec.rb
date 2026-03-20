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

    it "clears homeschool_name and homeschool_hours if teaches_homeschool is no" do
      screener = Screener.create(state: "NC")
      nc_screener = NcScreener.create(screener: screener, teaches_homeschool: "yes", homeschool_name: "Tough Nuts Academy", homeschool_hours: 25)

      nc_screener.update(teaches_homeschool: "no")

      expect(nc_screener.reload.homeschool_name).to be_nil
      expect(nc_screener.reload.homeschool_hours).to be_nil
    end

    it "preserves homeschool attributes if teaches_homeschool is yes" do
      screener = Screener.create(state: "NC")
      nc_screener = NcScreener.create(screener: screener, teaches_homeschool: "yes", homeschool_name: "Tough Nuts Academy", homeschool_hours: 25)

      nc_screener.update(teaches_homeschool: "yes")

      expect(nc_screener.reload.homeschool_name).to eq "Tough Nuts Academy"
      expect(nc_screener.reload.homeschool_hours).to eq 25
    end
  end
end

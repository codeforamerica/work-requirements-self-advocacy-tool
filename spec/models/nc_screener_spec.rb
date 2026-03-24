require "rails_helper"

RSpec.describe NcScreener, type: :model do
  describe "before_save" do
    it "clears worked_last_five_years if has_hs_diploma is yes" do
      nc_screener = create(:nc_screener, has_hs_diploma: "no", worked_last_five_years: "yes")

      nc_screener.update(has_hs_diploma: "yes")

      expect(nc_screener.reload.worked_last_five_years).to eq "unfilled"
    end

    it "preserves worked_last_five_years if has_hs_diploma is no" do
      nc_screener = create(:nc_screener, has_hs_diploma: "no", worked_last_five_years: "yes")

      nc_screener.update(has_hs_diploma: "no")

      expect(nc_screener.reload.worked_last_five_years).to eq "yes"
    end
  end

  describe "#at_least_55_no_diploma_not_working?" do
    it "returns true when age >= 55, no diploma, and not worked in last 5 years" do
      nc_screener = build(:nc_screener,
        screener: build(:screener, birth_date: 56.years.ago.to_date),
        has_hs_diploma: "no",
        worked_last_five_years: "no")

      expect(nc_screener.at_least_55_no_diploma_not_working?).to be true
    end

    it "returns false when age < 55" do
      nc_screener = build(:nc_screener,
        screener: build(:screener, birth_date: 54.years.ago.to_date),
        has_hs_diploma: "no",
        worked_last_five_years: "no")

      expect(nc_screener.at_least_55_no_diploma_not_working?).to be false
    end

    it "returns false when has a diploma" do
      nc_screener = build(:nc_screener,
        screener: build(:screener, birth_date: 56.years.ago.to_date),
        has_hs_diploma: "yes",
        worked_last_five_years: "no")

      expect(nc_screener.at_least_55_no_diploma_not_working?).to be false
    end

    it "returns false when worked in last 5 years" do
      nc_screener = build(:nc_screener,
        screener: build(:screener, birth_date: 56.years.ago.to_date),
        has_hs_diploma: "no",
        worked_last_five_years: "yes")

      expect(nc_screener.at_least_55_no_diploma_not_working?).to be false
    end
  end
end

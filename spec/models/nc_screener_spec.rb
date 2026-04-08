require "rails_helper"

RSpec.describe NcScreener, type: :model do
  describe "validations" do
    context "with_context :homeschool" do
      it "requires homeschool_hours to be an integer" do
        screener = create(:screener, state: "NC")
        nc_screener = build(:nc_screener, screener: screener, homeschool_hours: "abc")

        nc_screener.valid?(:homeschool)
        expect(nc_screener.errors[:homeschool_hours]).to be_present

        nc_screener.assign_attributes(homeschool_hours: 25)
        nc_screener.valid?(:homeschool)
        expect(nc_screener.errors[:homeschool_hours]).to be_empty
      end

      it "allows homeschool_hours to be blank" do
        screener = create(:screener, state: "NC")
        nc_screener = build(:nc_screener, screener: screener, homeschool_hours: nil)

        nc_screener.valid?(:homeschool)
        expect(nc_screener.errors[:homeschool_hours]).to be_empty
      end
    end
  end

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

    it "clears homeschool_name and homeschool_hours if teaches_homeschool is no" do
      screener = create(:screener, state: "NC")
      nc_screener = create(:nc_screener, screener: screener, teaches_homeschool: "yes", homeschool_name: "Tough Nuts Academy", homeschool_hours: 25)

      nc_screener.update(teaches_homeschool: "no")

      expect(nc_screener.reload.homeschool_name).to be_nil
      expect(nc_screener.reload.homeschool_hours).to be_nil
    end

    it "preserves homeschool attributes if teaches_homeschool is yes" do
      screener = create(:screener, state: "NC")
      nc_screener = create(:nc_screener, screener: screener, teaches_homeschool: "yes", homeschool_name: "Tough Nuts Academy", homeschool_hours: 25)

      nc_screener.update(teaches_homeschool: "yes")

      expect(nc_screener.reload.homeschool_name).to eq "Tough Nuts Academy"
      expect(nc_screener.reload.homeschool_hours).to eq 25
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

  describe "#operating_homeschool_30_or_more_hours?" do
    it "returns true when homeschool_hours >= 30" do
      nc_screener = build(:nc_screener, homeschool_hours: 30)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be true
    end

    it "returns false when homeschool_hours < 30" do
      nc_screener = build(:nc_screener, homeschool_hours: 29)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be false
    end

    it "returns false when homeschool_hours is nil" do
      nc_screener = build(:nc_screener)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be false
    end
  end

  describe "#exempt_from_work_rules?" do
    it "returns true when operating a homeschool for 30 or more hours" do
      nc_screener = build(:nc_screener, homeschool_hours: 30, worked_last_five_years: "no")
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns true when worked in the last five years" do
      nc_screener = build(:nc_screener, homeschool_hours: 10, worked_last_five_years: "yes")
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns true when both conditions are true" do
      nc_screener = build(:nc_screener, homeschool_hours: 30, worked_last_five_years: "yes")
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns false when neither condition is true" do
      nc_screener = build(:nc_screener, homeschool_hours: 10, worked_last_five_years: "no")
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false when homeschool_hours is nil and has not worked" do
      nc_screener = build(:nc_screener, homeschool_hours: nil, worked_last_five_years: "no")
      expect(nc_screener.exempt_from_work_rules?).to be false
    end
  end
end

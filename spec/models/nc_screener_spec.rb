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

  describe "#operating_homeschool_30_or_more_hours?" do
    it "returns true when homeschool_hours >= 30" do
      nc_screener = build(:nc_screener, teaches_homeschool: "yes", homeschool_hours: 30)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be true
    end

    it "returns false when homeschool_hours < 30" do
      nc_screener = build(:nc_screener, teaches_homeschool: "yes", homeschool_hours: 29)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be false
    end

    it "returns false when homeschool_hours is nil" do
      nc_screener = build(:nc_screener)
      expect(nc_screener.operating_homeschool_30_or_more_hours?).to be false
    end
  end

  describe "#age_work_education_health_exemption?" do
    it "returns true when age >= 55 && age <= 64 && worked_last_five_years_no? && has_hs_diploma_no? && preventing_work_medical_condition_yes?" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "no")
      create(:screener, state: "NC", birth_date: 56.years.ago.to_date, preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns false when age is not set" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "no")
      create(:screener, state: "NC", preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false when age is too young" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "no")
      create(:screener, state: "NC", birth_date: 20.years.ago.to_date, preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false when age is too old" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "no")
      create(:screener, state: "NC", birth_date: 70.years.ago.to_date, preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false worked_last_five_years is yes" do
      nc_screener = build(:nc_screener, worked_last_five_years: "yes", has_hs_diploma: "no")
      create(:screener, state: "NC", birth_date: 56.years.ago.to_date, preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false when has_hs_diploma is yes" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "yes")
      create(:screener, state: "NC", birth_date: 56.years.ago.to_date, preventing_work_medical_condition: "yes", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end

    it "returns false when preventing_work_medical_condition is no" do
      nc_screener = build(:nc_screener, worked_last_five_years: "no", has_hs_diploma: "no")
      create(:screener, state: "NC", birth_date: 56.years.ago.to_date, preventing_work_medical_condition: "no", nc_screener: nc_screener)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end
  end

  describe "#exempt_from_work_rules?" do
    it "returns true when operating a homeschool for 30 or more hours and age/work/education/health exemption is true" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(true)
      allow(nc_screener).to receive(:age_work_education_health_exemption?).and_return(true)
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns true when not operating a homeschool for 30 or more hours and age/work/education/health exemption is true" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(false)
      allow(nc_screener).to receive(:age_work_education_health_exemption?).and_return(true)
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns true when operating a homeschool for 30 or more hours and age/work/education/health exemption is false" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(true)
      allow(nc_screener).to receive(:age_work_education_health_exemption?).and_return(false)
      expect(nc_screener.exempt_from_work_rules?).to be true
    end

    it "returns false when not operating a homeschool for 30 or more hours and age/work/education/health exemption is false" do
      nc_screener = build(:nc_screener)
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(false)
      allow(nc_screener).to receive(:age_work_education_health_exemption?).and_return(false)
      expect(nc_screener.exempt_from_work_rules?).to be false
    end
  end
end

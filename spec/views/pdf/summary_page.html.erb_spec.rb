require "rails_helper"

RSpec.describe "pdf/summary_page", type: :view do
  let(:default_locals) do
    {
      at_least_55_no_diploma_not_working: false,
      operating_homeschool_30_or_more_hours: false,
      full_name: "Nelly Ghaffar",
      birth_date: "1990-07-13",
      caring_for_child_under_6: false,
      caring_for_disabled_or_ill_person: false,
      has_unemployment_benefits: false,
      in_drug_or_alcohol_program: false,
      enrolled_in_education: false,
      working_30_or_more_hours: false,
      earnings_above_minimum: false,
      has_child: false,
      is_pregnant: false,
      pregnancy_due_date: "",
      receiving_disability_benefits: false,
      is_american_indian: false,
      seasonal_worker: false,
      any_preventing_work: false,
      preventing_work_place_to_sleep: false,
      preventing_work_domestic_violence: false,
      preventing_work_drugs_alcohol: false,
      preventing_work_medical_condition: false,
      preventing_work_other: false,
      work_hours: 0,
      volunteering_hours: 0,
      work_training_hours: 0,
      weekly_earnings: 0.0
    }
  end

  def render_page(overrides = {})
    locals = default_locals.merge(overrides)
    render template: "pdf/summary_page", locals: locals
  end

  it "always displays the header, attestation, and footer" do
    render_page
    expect(rendered).to include("SNAP Work Requirement Exemptions Attestation")
    expect(rendered).to include("Nelly Ghaffar, (DOB: July 13, 1990) attests to the following")
    expect(rendered).to include("See the following page for details.")
  end

  describe "General Work Requirement Exemptions section" do
    it "is not shown when no general exemptions apply" do
      render_page
      expect(rendered).not_to include("General Work Requirement Exemptions")
    end

    it "shows caring for child under 6" do
      render_page(caring_for_child_under_6: true)
      expect(rendered).to include("General Work Requirement Exemptions")
      expect(rendered).to include("Caring for a child under 6 years old")
    end

    it "shows caring for incapacitated person" do
      render_page(caring_for_disabled_or_ill_person: true)
      expect(rendered).to include("Caring for an incapacitated person")
    end

    it "shows unemployment benefits" do
      render_page(has_unemployment_benefits: true)
      expect(rendered).to include("Currently getting unemployment benefits")
    end

    it "shows drug or alcohol program" do
      render_page(in_drug_or_alcohol_program: true)
      expect(rendered).to include("Participating regularly in an alcohol or drug treatment program")
    end

    it "shows enrolled in education" do
      render_page(enrolled_in_education: true)
      expect(rendered).to include("Enrolled in a school, training program")
    end

    it "shows working 30 or more hours" do
      render_page(working_30_or_more_hours: true)
      expect(rendered).to include("Working at least 30 hours a week")
    end

    it "shows seasonal worker" do
      render_page(seasonal_worker: true)
      expect(rendered).to include("General Work Requirement Exemptions")
      expect(rendered).to include("Seasonal or migrant farmworker")
    end

    it "shows earnings above minimum" do
      render_page(earnings_above_minimum: true)
      expect(rendered).to include("Earning at least $217.50 a week")
    end

    it "shows operating a homeschool 30 or more hours" do
      render_page(operating_homeschool_30_or_more_hours: true)
      expect(rendered).to include("Operating a home school for at least 30 hours a week")
    end

    it "only shows applicable bullets" do
      render_page(caring_for_child_under_6: true, enrolled_in_education: true)
      expect(rendered).to include("Caring for a child under 6 years old")
      expect(rendered).to include("Enrolled in a school, training program")
      expect(rendered).not_to include("Caring for an incapacitated person")
      expect(rendered).not_to include("Working at least 30 hours a week")
    end
  end

  describe "ABAWD Work Requirement Exemptions section" do
    it "is not shown when no ABAWD exemptions apply" do
      render_page
      expect(rendered).not_to include("Able-Bodied Adult Without Dependents")
    end

    it "shows living with a child" do
      render_page(has_child: true)
      expect(rendered).to include("Able-Bodied Adult Without Dependents")
      expect(rendered).to include("Living with a child under 14 years old")
    end

    it "shows pregnant with due date" do
      render_page(is_pregnant: true, pregnancy_due_date: "2026-09-15")
      expect(rendered).to include("Pregnant (Due: September 15, 2026)")
    end

    it "shows receiving a disability benefit" do
      render_page(receiving_disability_benefits: true)
      expect(rendered).to include("Receiving a disability benefit")
    end

    it "shows American Indian tribe member" do
      render_page(is_american_indian: true)
      expect(rendered).to include("A member of an Indian tribe or nation")
    end

    describe "preventing work sub-bullets" do
      it "shows the unfit for work header when any preventing work condition is true" do
        render_page(any_preventing_work: true, preventing_work_place_to_sleep: true)
        expect(rendered).to include("Unfit for work")
      end

      it "shows at least 55 no diploma not working sub-bullet" do
        render_page(any_preventing_work: true, at_least_55_no_diploma_not_working: true)
        expect(rendered).to include("At least 55 years old without a high school diploma")
      end

      it "shows place to sleep sub-bullet" do
        render_page(any_preventing_work: true, preventing_work_place_to_sleep: true)
        expect(rendered).to include("Does not have a regular place to sleep or shower")
      end

      it "shows domestic violence sub-bullet" do
        render_page(any_preventing_work: true, preventing_work_domestic_violence: true)
        expect(rendered).to include("Experiencing domestic violence")
      end

      it "shows substance use disorder sub-bullet" do
        render_page(any_preventing_work: true, preventing_work_drugs_alcohol: true)
        expect(rendered).to include("Substance use disorder")
      end

      it "shows medical condition sub-bullet" do
        render_page(any_preventing_work: true, preventing_work_medical_condition: true)
        expect(rendered).to include("Has a physical or mental medical condition")
      end

      it "shows other sub-bullet" do
        render_page(any_preventing_work: true, preventing_work_other: true)
        expect(rendered).to include("Other")
      end

      it "only shows applicable sub-bullets" do
        render_page(
          any_preventing_work: true,
          preventing_work_place_to_sleep: true,
          preventing_work_domestic_violence: true
        )
        expect(rendered).to include("Does not have a regular place to sleep or shower")
        expect(rendered).to include("Experiencing domestic violence")
        expect(rendered).not_to include("Substance use disorder")
        expect(rendered).not_to include("Has a physical or mental medical condition")
      end
    end
  end
end

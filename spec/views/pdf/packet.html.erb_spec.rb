require "rails_helper"

RSpec.describe "pdf/packet", type: :view do
  let(:default_locals) do
    {
      full_name_with_middle: "Nelly Lucy Ghaffar",
      age: "36",
      birth_date: "1990-07-13",
      phone_number: "(919) 555-1234",
      email: "nelly@example.com",
      case_number: "123456789",
      ssn_last_4: "1234",
      is_american_indian: false,
      has_child: false,
      caring_for_child_under_6: false,
      caring_for_disabled_or_ill_person: false,
      details_of_care: nil,
      is_pregnant: false,
      pregnancy_due_date: "",
      has_unemployment_benefits: false,
      receiving_disability_benefits: false,
      receiving_benefits_ssdi: false,
      receiving_benefits_ssi: false,
      receiving_benefits_veterans_disability: false,
      receiving_benefits_workers_compensation: false,
      receiving_benefits_disability_pension: false,
      receiving_benefits_insurance_payments: false,
      receiving_benefits_disability_medicaid: false,
      receiving_benefits_other: false,
      receiving_benefits_write_in: nil,
      working_or_earning: false,
      work_hours: nil,
      earnings_per_week: nil,
      seasonal_worker: false,
      operating_a_homeschool: false,
      homeschool_hours: nil,
      homeschool_name: nil,
      is_in_work_training: false,
      work_training_hours: nil,
      work_training_name: nil,
      is_volunteering: false,
      volunteering_hours: nil,
      volunteering_org_name: nil,
      enrolled_in_education: false,
      in_drug_or_alcohol_program: false,
      drug_alcohol_program_name: nil,
      at_least_55_no_diploma_not_working: false,
      preventing_work_place_to_sleep: false,
      preventing_work_drugs_alcohol: false,
      preventing_work_domestic_violence: false,
      preventing_work_medical_condition: false,
      preventing_work_other: false,
      preventing_work_other_write_in: nil,
      preventing_work_write_in: nil,
      signature: "Nelly Ghaffar",
      submission_date: "August 10, 2026",
      confirmation_code: "ABC123",
      state: LocationData::States::DELAWARE,
      working_30_or_more_hours: false,
      earnings_above_minimum: false,
      operating_homeschool_30_or_more_hours: false,
      any_preventing_work: false
    }
  end

  def render_page(overrides = {})
    locals = default_locals.merge(overrides)
    render template: "pdf/packet", locals: locals
  end

  describe "Summary page" do
    it "always displays the header and Client Information" do
      render_page
      expect(rendered).to include("SNAP Work Requirement Exemptions")
      expect(rendered).to include("Client Information")
      expect(rendered).to include("Nelly Lucy Ghaffar")
      expect(rendered).to include("1990-07-13, (Age 36)")
      expect(rendered).to include("(919) 555-1234")
      expect(rendered).to include("nelly@example.com")
      expect(rendered).to include("123456789")
      expect(rendered).to include("1234")
    end

    it "renders Client Information before (outside of) the grey-box exemptions section" do
      render_page
      expect(rendered.index("Client Information")).to be < rendered.index("grey-box")
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

      it "does NOT show due date when blank" do
        render_page(is_pregnant: true, pregnancy_due_date: "")
        expect(rendered).to include("Pregnant")
        expect(rendered).not_to include("(Due:")
      end

      it "does NOT show due date when nil" do
        render_page(is_pregnant: true, pregnancy_due_date: nil)
        expect(rendered).to include("Pregnant")
        expect(rendered).not_to include("(Due:")
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

  describe "Details page" do
    it "always displays Signature regardless of exemptions" do
      render_page
      expect(rendered).to include("Signature")
    end

    describe "Reported Exemptions section" do
      it "is not shown when no exemptions apply" do
        render_page
        expect(rendered).not_to include("Reported Exemptions")
      end

      it "is shown, with only the applicable item, when one exemption applies" do
        render_page(is_american_indian: true)
        expect(rendered).to include("Reported Exemptions")
        expect(rendered).to include("I am a member of an Indian tribe or nation")
        expect(rendered).not_to include("I live with a child under 14")
        expect(rendered).not_to include("I am a seasonal or migrant farmworker")
      end
    end

    describe "Fitness for Work section" do
      it "is not shown when no preventing-work reasons apply" do
        render_page
        expect(rendered).not_to include("Fitness for Work")
      end

      it "is shown, with only the applicable item, when one reason applies" do
        render_page(preventing_work_medical_condition: true)
        expect(rendered).to include("Fitness for Work")
        expect(rendered).to include("I have a physical or mental medical condition")
        expect(rendered).not_to include(">Other<")
      end
    end

    describe "NC-only fields" do
      it "are hidden for a Delaware screener" do
        render_page(state: LocationData::States::DELAWARE)
        expect(rendered).not_to include("I am operating a home school")
        expect(rendered).not_to include("I do not have a regular place to sleep and shower")
        expect(rendered).not_to include("I am struggling with drugs or alcohol")
        expect(rendered).not_to include("I am experiencing domestic violence")
        expect(rendered).not_to include("I am 55 to 64 years old")
      end

      it "shows the homeschool exemption for a North Carolina screener" do
        render_page(
          state: LocationData::States::NORTH_CAROLINA,
          operating_a_homeschool: true,
          homeschool_hours: "20",
          homeschool_name: "Small Fry"
        )
        expect(rendered).to include("I am operating a home school for at least 30 hours a week")
        expect(rendered).to include("Hours a week operating home school: 20")
        expect(rendered).to include("Name of the home school: Small Fry")
      end

      it "shows the NC-only fitness-for-work reasons for a North Carolina screener" do
        render_page(
          state: LocationData::States::NORTH_CAROLINA,
          at_least_55_no_diploma_not_working: true,
          preventing_work_place_to_sleep: true,
          preventing_work_drugs_alcohol: true,
          preventing_work_domestic_violence: true
        )
        expect(rendered).to include("I am 55 to 64 years old, I do not have a high school diploma or GED")
        expect(rendered).to include("I do not have a regular place to sleep and shower")
        expect(rendered).to include("I am struggling with drugs or alcohol")
        expect(rendered).to include("I am experiencing domestic violence")
      end

      it "hides the homeschool item and its details when not checked, even for a North Carolina screener" do
        render_page(state: LocationData::States::NORTH_CAROLINA)
        expect(rendered).not_to include("I am operating a home school for at least 30 hours a week")
        expect(rendered).not_to include("Hours a week operating home school:")
        expect(rendered).not_to include("Name of the home school:")
      end
    end
  end
end

require "rails_helper"

RSpec.describe "pdf/filled_packet", type: :view do
  let(:default_locals) do
    {
      full_name_with_middle: "Nelly Lucy Ghaffar",
      birth_date: "July 13, 1990",
      age: "36",
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
      pregnancy_due_date: nil,
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
      state: LocationData::States::DELAWARE
    }
  end

  def render_page(overrides = {})
    locals = default_locals.merge(overrides)
    render template: "pdf/filled_packet", locals: locals
  end

  it "always displays the shared checklist regardless of state" do
    render_page
    expect(rendered).to include("I am a member of an Indian tribe or nation")
    expect(rendered).to include("I am a seasonal or migrant farmworker")
    expect(rendered).to include("I have a physical or mental medical condition")
    expect(rendered).to include("Signature")
  end

  describe "NC-only fields" do
    it "are hidden for a Delaware screener" do
      render_page(state: LocationData::States::DELAWARE)
      expect(rendered).not_to include("I am operating a home school")
      expect(rendered).not_to include("I do not have a regular place to sleep and shower")
      expect(rendered).not_to include("I am struggling with drugs or alcohol")
      expect(rendered).not_to include("I am experiencing domestic violence")
      expect(rendered).not_to include("I am at least 55 years old without a high school diploma")
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
      expect(rendered).to include("I am at least 55 years old without a high school diploma")
      expect(rendered).to include("I do not have a regular place to sleep and shower")
      expect(rendered).to include("I am struggling with drugs or alcohol")
      expect(rendered).to include("I am experiencing domestic violence")
    end

    it "does not render the homeschool detail lines when NC fields are false" do
      render_page(state: LocationData::States::NORTH_CAROLINA)
      expect(rendered).to include("I am operating a home school for at least 30 hours a week")
      expect(rendered).not_to include("Hours a week operating home school:")
      expect(rendered).not_to include("Name of the home school:")
    end
  end
end

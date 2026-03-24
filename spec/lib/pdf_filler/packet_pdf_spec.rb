require "rails_helper"

RSpec.describe PdfFiller::PacketPdf do
  include ActiveSupport::Testing::TimeHelpers

  let(:screener) do
    Screener.new(
      first_name: "Nigella",
      middle_name: "Lucy",
      last_name: "Lawson",
      birth_date: Date.new(1990, 7, 13),
      email: "nigella@example.com",
      phone_number: "9195551234",
      state: LocationData::States::NORTH_CAROLINA,
      nc_screener: NcScreener.new
    )
  end

  subject(:packet_pdf) { described_class.new(screener) }

  describe "#hash_for_fillable_pdf" do
    subject(:result) { packet_pdf.hash_for_fillable_pdf }

    describe "direct screener mappings" do
      it "maps full_name_with_middle from screener" do
        expect(result[:full_name_with_middle]).to eq("Nigella Lucy Lawson")
      end

      it "maps full_name_with_middle without middle name when absent" do
        screener.middle_name = nil
        expect(result[:full_name_with_middle]).to eq("Nigella Lawson")
      end

      it "maps birth_date as a string" do
        expect(result[:birth_date]).to eq("1990-07-13")
      end

      it "maps email" do
        expect(result[:email]).to eq("nigella@example.com")
      end

      it "maps phone_number" do
        expect(result[:phone_number]).to eq("(919) 555-1234")
      end

      it "maps boolean enum fields" do
        screener.is_american_indian = "yes"
        screener.has_child = "no"
        expect(result[:is_american_indian]).to be true
        expect(result[:has_child]).to be false
      end

      it "maps string fields from screener" do
        screener.work_training_name = "Job Corps"
        screener.work_training_hours = "25"
        screener.receiving_benefits_write_in = "Other disability"
        screener.volunteering_org_name = "Food Bank"
        screener.preventing_work_write_in = "Back pain"
        screener.alcohol_treatment_program_name = "AA Program"
        screener.additional_care_info = "Caring for my mother"

        expect(result[:work_training_name]).to eq("Job Corps")
        expect(result[:work_training_hours]).to eq("25")
        expect(result[:receiving_benefits_write_in]).to eq("Other disability")
        expect(result[:volunteering_org_name]).to eq("Food Bank")
        expect(result[:preventing_work_write_in]).to eq("Back pain")
        expect(result[:drug_alcohol_program_name]).to eq("AA Program")
        expect(result[:details_of_care]).to eq("Caring for my mother")
      end

      it "maps pregnancy_due_date as a string" do
        screener.pregnancy_due_date = Date.new(2026, 9, 15)
        expect(result[:pregnancy_due_date]).to eq("2026-09-15")
      end

      it "maps work_hours from working_hours as a string" do
        screener.working_hours = 35
        expect(result[:work_hours]).to eq("35")
      end

      it "maps earnings_per_week from working_weekly_earnings as a string" do
        screener.working_weekly_earnings = 250.00
        expect(result[:earnings_per_week]).to eq("250.0")
      end

      it "maps seasonal_worker from is_migrant_farmworker" do
        screener.is_migrant_farmworker = "yes"
        expect(result[:seasonal_worker]).to be true
      end

      it "maps enrolled_in_education from is_student" do
        screener.is_student = "yes"
        expect(result[:enrolled_in_education]).to be true
      end

      it "maps in_drug_or_alcohol_program from is_in_alcohol_treatment_program" do
        screener.is_in_alcohol_treatment_program = "yes"
        expect(result[:in_drug_or_alcohol_program]).to be true
      end

      it "maps receiving_benefits_disability_medicaid" do
        screener.receiving_benefits_disability_medicaid = "yes"
        expect(result[:receiving_benefits_disability_medicaid]).to be true
      end
    end

    describe "submission_date and submission_date_2" do
      it "sets both to the current date" do
        travel_to Date.new(2026, 1, 9) do
          expect(result[:submission_date]).to eq("2026-01-09")
          expect(result[:submission_date_2]).to eq("2026-01-09")
        end
      end
    end

    describe "age" do
      it "delegates to screener.age and converts to string" do
        travel_to Date.new(2026, 1, 9) do
          expect(result[:age]).to eq("35")
        end
      end

      it "returns empty string when birth_date is nil" do
        screener.birth_date = nil
        expect(result[:age]).to eq("")
      end
    end

    describe "delegated calculated fields" do
      it "delegates receiving_disabilty_benefits to screener" do
        expect(result[:receiving_disabilty_benefits]).to be false
        screener.receiving_benefits_ssdi = "yes"
        expect(packet_pdf.hash_for_fillable_pdf[:receiving_disabilty_benefits]).to be true
      end

      it "delegates working_or_earning to screener" do
        expect(result[:working_or_earning]).to be false
        screener.is_working = "yes"
        screener.working_hours = 30
        expect(packet_pdf.hash_for_fillable_pdf[:working_or_earning]).to be true
      end

      it "delegates is_volunteering to screener" do
        expect(result[:is_volunteering]).to be false
        screener.is_volunteer = "yes"
        screener.volunteering_hours = 1
        expect(packet_pdf.hash_for_fillable_pdf[:is_volunteering]).to be true
      end
    end
  end

  describe "#filled_pdf_path" do
    it "fills the PDF without errors" do
      screener.assign_attributes(
        phone_number: "9195550123",
        is_american_indian: "yes",
        has_child: "yes",
        caring_for_child_under_6: "yes",
        caring_for_disabled_or_ill_person: "yes",
        additional_care_info: "Caring for my mother",
        is_pregnant: "yes",
        pregnancy_due_date: Date.new(2026, 9, 15),
        has_unemployment_benefits: "yes",
        receiving_benefits_ssdi: "yes",
        is_working: "yes",
        working_hours: 35,
        working_weekly_earnings: 250.00,
        is_volunteer: "yes",
        volunteering_hours: 10,
        volunteering_org_name: "Food Bank",
        is_in_work_training: "yes",
        work_training_name: "Job Corps",
        work_training_hours: "15",
        is_student: "yes",
        is_migrant_farmworker: "yes",
        is_in_alcohol_treatment_program: "yes",
        alcohol_treatment_program_name: "Recovery Program",
        preventing_work_place_to_sleep: "yes",
        preventing_work_domestic_violence: "yes",
        preventing_work_drugs_alcohol: "yes",
        preventing_work_medical_condition: "yes",
        preventing_work_other: "yes",
        preventing_work_write_in: "Chronic back pain"
      )

      expect { packet_pdf.filled_pdf_path }.not_to raise_error
    end
  end

  describe "#hash_for_generated_pdf" do
    subject(:result) { packet_pdf.hash_for_generated_pdf }

    it "includes full_name" do
      expect(result[:full_name]).to eq("Nigella Lawson")
    end

    it "includes birth_date" do
      expect(result[:birth_date]).to eq("1990-07-13")
    end

    it "converts working_hours to integer" do
      screener.working_hours = 25
      expect(result[:work_hours]).to eq(25)
    end

    it "converts volunteering_hours to integer" do
      screener.volunteering_hours = 10
      expect(result[:volunteering_hours]).to eq(10)
    end

    it "converts work_training_hours to integer" do
      screener.work_training_hours = "15"
      expect(result[:work_training_hours]).to eq(15)
    end

    it "converts working_weekly_earnings to float" do
      screener.working_weekly_earnings = 220
      expect(result[:weekly_earnings]).to eq(220.0)
    end

    it "defaults nil numeric fields to zero" do
      expect(result[:work_hours]).to eq(0)
      expect(result[:volunteering_hours]).to eq(0)
      expect(result[:work_training_hours]).to eq(0)
      expect(result[:weekly_earnings]).to eq(0.0)
    end

    it "delegates calculated boolean fields to screener" do
      screener.receiving_benefits_ssdi = "yes"
      screener.working_hours = 35
      screener.preventing_work_domestic_violence = "yes"

      expect(result[:receiving_disability_benefits]).to be true
      expect(result[:working_30_or_more_hours]).to be true
      expect(result[:earnings_above_minimum]).to be false
      expect(result[:any_preventing_work]).to be true
    end
  end
end

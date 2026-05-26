require "rails_helper"

RSpec.describe PdfFiller::PacketPdf do
  include ActiveSupport::Testing::TimeHelpers

  let(:screener) do
    build(:screener,
      first_name: "Nigella",
      middle_name: "Lucy",
      last_name: "Lawson",
      birth_date: Date.new(1990, 7, 13),
      email: "nigella@example.com",
      phone_number: "9195551234",
      state: LocationData::States::NORTH_CAROLINA)
  end

  subject(:packet_pdf) { described_class.new(screener) }

  # Field names that only belong on the earnings-exemption PDF template
  let(:earnings_only_fillable_keys) do
    %i[
      earnings_per_week
      is_in_work_training
      is_volunteering
      submission_date_2
      volunteering_hours
      volunteering_org_name
      work_hours
      work_training_name
      working_or_earning
    ]
  end

  let(:earnings_only_shared_keys) { %i[volunteering_hours work_hours work_training_hours] }

  describe "#hash_for_fillable_pdf" do
    subject(:result) { packet_pdf.hash_for_fillable_pdf }

    describe "direct field mappings" do
      {
        caring_for_child_under_6: :caring_for_child_under_6,
        caring_for_disabled_or_ill_person: :caring_for_disabled_or_ill_person,
        enrolled_in_education: :is_student,
        has_child: :has_child,
        has_unemployment_benefits: :has_unemployment_benefits,
        in_drug_or_alcohol_program: :is_in_alcohol_treatment_program,
        is_american_indian: :is_american_indian,
        is_pregnant: :is_pregnant,
        preventing_work_domestic_violence: :preventing_work_domestic_violence,
        preventing_work_drugs_alcohol: :preventing_work_drugs_alcohol,
        preventing_work_medical_condition: :preventing_work_medical_condition,
        preventing_work_other: :preventing_work_other,
        preventing_work_place_to_sleep: :preventing_work_place_to_sleep,
        receiving_benefits_disability_medicaid: :receiving_benefits_disability_medicaid,
        seasonal_worker: :is_migrant_farmworker
      }.each do |pdf_field, screener_attr|
        it "maps #{pdf_field} from #{screener_attr}" do
          screener.public_send("#{screener_attr}=", "yes")
          expect(result[pdf_field]).to be true
        end
      end

      it "maps string fields from screener" do
        screener.additional_care_info = "Babysitting Paul Hollywood"
        screener.alcohol_treatment_program_name = "Alcolisti Anonimi"
        screener.case_number = "543212345"
        screener.confirmation_code = "ABQ39L"
        screener.preventing_work_write_in = "Back pain"
        screener.preventing_work_additional_info = "I am carrying the weight of the world on my back."
        screener.receiving_benefits_write_in = "Other disability"
        screener.signature = "Nigellla Lawson"
        screener.ssn_last_four = "1111"

        expect(result[:details_of_care]).to eq("Babysitting Paul Hollywood")
        expect(result[:drug_alcohol_program_name]).to eq("Alcolisti Anonimi")
        expect(result[:case_number]).to eq("543212345")
        expect(result[:confirmation_code]).to eq("ABQ39L")
        expect(result[:email]).to eq("nigella@example.com")
        expect(result[:phone_number]).to eq("(919) 555-1234")
        expect(result[:preventing_work_other_write_in]).to eq("Back pain")
        expect(result[:preventing_work_write_in]).to eq("I am carrying the weight of the world on my back.")
        expect(result[:receiving_benefits_write_in]).to eq("Other disability")
        expect(result[:signature]).to eq("Nigellla Lawson")
        expect(result[:ssn_last_4]).to eq("1111")
      end

      it "maps date and numeric fields as strings" do
        screener.pregnancy_due_date = Date.new(2026, 9, 15)

        expect(result[:birth_date]).to eq("July 13, 1990")
        expect(result[:pregnancy_due_date]).to eq("September 15, 2026")
      end
    end

    describe "calculated fields" do
      it "delegates age to screener and converts to string" do
        allow(screener).to receive(:age).and_return(35)
        expect(result[:age]).to eq("35")
      end

      it "returns empty string for age when screener.age is nil" do
        allow(screener).to receive(:age).and_return(nil)
        expect(result[:age]).to eq("")
      end

      it "delegates full_name_with_middle to screener" do
        allow(screener).to receive(:full_name_with_middle).and_return("Nigella Lucy Lawson")
        expect(result[:full_name_with_middle]).to eq("Nigella Lucy Lawson")
      end

      it "delegates receiving_disabilty_benefits to screener" do
        allow(screener).to receive(:receiving_disability_benefits?).and_return(true)
        expect(result[:receiving_disabilty_benefits]).to be true
      end
    end

    it "sets submission_date to the current date" do
      travel_to Date.new(2026, 1, 9) do
        expect(result[:submission_date]).to eq("January 9, 2026")
      end
    end

    context "screener has a regular exemption" do
      before { screener.assign_attributes(preventing_work_medical_condition: "yes") }

      it "does not include any work, volunteer, or training fields" do
        earnings_only_fillable_keys.each do |key|
          expect(result).not_to have_key(key),
            "expected #{key.inspect} not to appear for a regular exemption screener, but it did"
        end
      end

      it "does not include work/volunteer/training hours even if those columns happen to hold values" do
        screener.assign_attributes(
          working_hours: 35,
          working_weekly_earnings: 250.00,
          volunteering_hours: 10,
          volunteering_org_name: "Muffins for Mums",
          work_training_hours: 15,
          work_training_name: "Bake Off Boot Camp"
        )

        earnings_only_fillable_keys.each do |key|
          expect(result).not_to have_key(key)
        end
      end
    end

    context "screener has only the earnings exemption" do
      before do
        screener.assign_attributes(
          is_working: "yes",
          working_hours: 35,
          working_weekly_earnings: 250.00,
          is_volunteer: "yes",
          volunteering_hours: 10,
          volunteering_org_name: "Muffins for Mums",
          is_in_work_training: "yes",
          work_training_hours: 15,
          work_training_name: "Bake Off Boot Camp"
        )
      end

      it "maps earnings, work, volunteer, and training fields" do
        expect(result[:earnings_per_week]).to eq("250.0")
        expect(result[:work_hours]).to eq("35")
        expect(result[:volunteering_hours]).to eq("10")
        expect(result[:volunteering_org_name]).to eq("Muffins for Mums")
        expect(result[:work_training_name]).to eq("Bake Off Boot Camp")
      end

      it "delegates working_or_earning to has_earnings_exemption?" do
        expect(result[:working_or_earning]).to be true
      end

      it "delegates is_volunteering to screener" do
        expect(result[:is_volunteering]).to be true
      end

      it "delegates is_in_work_training to screener" do
        expect(result[:is_in_work_training]).to be true
      end
    end
  end

  describe "#hash_for_generated_pdf" do
    subject(:result) { packet_pdf.hash_for_generated_pdf }

    it "delegates fields with helper methods to screener" do
      allow(screener).to receive(:full_name).and_return("Nigella Lawson")
      allow(screener).to receive(:receiving_disability_benefits?).and_return(true)
      allow(screener).to receive(:working_30_or_more_hours?).and_return(true)
      allow(screener).to receive(:earnings_above_minimum?).and_return(false)
      allow(screener).to receive(:any_preventing_work?).and_return(true)

      expect(result[:full_name]).to eq("Nigella Lawson")
      expect(result[:receiving_disability_benefits]).to be true
      expect(result[:working_30_or_more_hours]).to be true
      expect(result[:earnings_above_minimum]).to be false
      expect(result[:any_preventing_work]).to be true
    end

    context "screener has a regular exemption" do
      before { screener.assign_attributes(preventing_work_medical_condition: "yes") }

      it "does not include work/volunteer/training hours" do
        earnings_only_shared_keys.each do |key|
          expect(result).not_to have_key(key)
        end
      end

      it "defaults top-level work/volunteer/training/earnings to zero so the summary page skips those sections" do
        expect(result[:working_30_or_more_hours]).to be false
        expect(result[:earnings_above_minimum]).to be false
      end
    end

    context "screener has only the earnings exemption" do
      before do
        screener.assign_attributes(
          is_working: "yes",
          working_hours: 25,
          working_weekly_earnings: 220,
          is_volunteer: "yes",
          volunteering_hours: 10,
          is_in_work_training: "yes",
          work_training_hours: 15
        )
      end

      it "includes work/volunteer/training hours" do
        expect(result[:work_hours]).to eq(25)
        expect(result[:volunteering_hours]).to eq(10)
        expect(result[:work_training_hours]).to eq("15")
      end
    end
  end

  describe "#filled_pdf_tempfile" do
    context "screener has a regular exemption" do
      before do
        screener.assign_attributes(
          phone_number: "9195550123",
          is_american_indian: "yes",
          has_child: "yes",
          caring_for_child_under_6: "yes",
          caring_for_disabled_or_ill_person: "yes",
          additional_care_info: "Babysitting Paul Hollywood",
          is_pregnant: "yes",
          pregnancy_due_date: Date.new(2026, 9, 15),
          has_unemployment_benefits: "yes",
          receiving_benefits_ssdi: "yes",
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
      end

      it "uses the no-income template" do
        expect(HexaPDF::Document).to receive(:open)
          .with("app/assets/pdfs/packet--no-income.pdf")
          .and_call_original

        path = packet_pdf.filled_pdf_tempfile.path
        File.delete(path) if path && File.exist?(path)
      end

      it "fills and flattens the PDF (no editable fields remain)" do
        path = nil

        expect {
          path = packet_pdf.filled_pdf_tempfile.path
        }.not_to raise_error

        doc = HexaPDF::Document.open(path)
        form = doc.acro_form
        expect(form).to be_nil.or have_attributes(fields: be_empty)
      ensure
        File.delete(path) if path && File.exist?(path)
      end
    end

    context "screener has only the earnings exemption" do
      before do
        screener.assign_attributes(
          phone_number: "9195550123",
          is_working: "yes",
          working_hours: 35,
          working_weekly_earnings: 250.00,
          is_volunteer: "yes",
          volunteering_hours: 10,
          volunteering_org_name: "Muffins for Mums",
          is_in_work_training: "yes",
          work_training_name: "Bake Off Boot Camp",
          work_training_hours: "15"
        )
      end

      it "uses the income-capable template" do
        expect(HexaPDF::Document).to receive(:open)
          .with("app/assets/pdfs/packet.pdf")
          .and_call_original

        path = packet_pdf.filled_pdf_tempfile.path
        File.delete(path) if path && File.exist?(path)
      end

      it "fills and flattens the PDF (no editable fields remain)" do
        path = nil

        expect {
          path = packet_pdf.filled_pdf_tempfile.path
        }.not_to raise_error

        doc = HexaPDF::Document.open(path)
        form = doc.acro_form
        expect(form).to be_nil.or have_attributes(fields: be_empty)
      ensure
        File.delete(path) if path && File.exist?(path)
      end
    end
  end

  describe "#combined_pdf" do
    let(:screener) do
      build(:screener,
        first_name: "Nigella",
        last_name: "Lawson",
        birth_date: Date.new(1990, 7, 13),
        state: LocationData::States::DELAWARE,
        county: nil,
        preventing_work_medical_condition: "yes")
    end

    it "returns a single PDF combining the summary page and the filled packet" do
      filled_path = nil
      # Skip headless Chrome; write a real 1-page PDF where Grover would have
      # written, so HexaPDF can read and merge it back in.
      allow_any_instance_of(Grover).to receive(:to_pdf) do |_, path|
        doc = HexaPDF::Document.new
        doc.pages.add
        doc.write(path)
      end
      # Capture the filled-packet tempfile path so we can clean it up.
      allow(packet_pdf).to receive(:filled_pdf_tempfile).and_wrap_original do |original|
        filled_path = original.call
      end

      result = packet_pdf.combined_pdf

      expect(result).to start_with("%PDF")
      merged = HexaPDF::Document.new(io: StringIO.new(result))
      # one summary page + the filled-packet template's pages
      expect(merged.pages.count).to be >= 2
    ensure
      File.delete(filled_path.path) if filled_path&.path && File.exist?(filled_path.path)
    end
  end

  describe "#strip_emojis" do
    it "removes simple emoji characters" do
      text = "Hello 😊 world 👍"
      expect(packet_pdf.strip_emojis(text)).to eq("Hello world")
    end

    it "removes complex emoji sequences with zero-width joiners" do
      text = "Family 👨‍👩‍👧‍👦 test"
      expect(packet_pdf.strip_emojis(text)).to eq("Family test")
    end

    it "normalizes extra whitespace after removal" do
      text = "Hello 😊   world"
      expect(packet_pdf.strip_emojis(text)).to eq("Hello world")
    end

    it "returns a clean string when no emojis are present" do
      text = "Just plain text"
      expect(packet_pdf.strip_emojis(text)).to eq("Just plain text")
    end
  end
end

require "rails_helper"

RSpec.describe PdfFiller::NcPacketPdf do
  let(:nc_screener) { create(:nc_screener) }
  let(:screener) do
    build(:screener,
      first_name: "Nigella",
      middle_name: "Lucy",
      last_name: "Lawson",
      birth_date: Date.new(1990, 7, 13),
      email: "nigella@example.com",
      phone_number: "9195551234",
      state: LocationData::States::NORTH_CAROLINA,
      nc_screener: nc_screener)
  end

  subject(:packet_pdf) { described_class.new(screener) }

  describe "#hash_for_fillable_pdf" do
    subject(:result) { packet_pdf.hash_for_fillable_pdf }

    it "direct field mappings" do
      nc_screener.teaches_homeschool = "yes"
      screener.preventing_work_place_to_sleep = "yes"
      screener.preventing_work_domestic_violence = "yes"
      screener.preventing_work_drugs_alcohol = "yes"

      expect(result[:operating_a_homeschool]).to be true
      expect(result[:preventing_work_place_to_sleep]).to be true
      expect(result[:preventing_work_domestic_violence]).to be true
      expect(result[:preventing_work_drugs_alcohol]).to be true
    end

    it "maps homeschool_name from nc_screener" do
      nc_screener.homeschool_name = "Small Fry"
      expect(result[:homeschool_name]).to eq("Small Fry")
    end

    it "maps homeschool_hours as a string" do
      nc_screener.homeschool_hours = 20
      expect(result[:homeschool_hours]).to eq("20")
    end

    it "delegates at_least_55_no_diploma_not_working to nc_screener" do
      allow(nc_screener).to receive(:age_work_education_health_exemption?).and_return(true)
      expect(result[:at_least_55_no_diploma_not_working]).to be true
    end
  end

  describe "#hash_for_generated_pdf" do
    subject(:result) { packet_pdf.hash_for_generated_pdf }

    it "delegates operating_homeschool_30_or_more_hours to nc_screener" do
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(false)
      expect(result[:operating_homeschool_30_or_more_hours]).to be false
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
          .with("app/assets/pdfs/nc_packet--no-income.pdf")
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
          .with("app/assets/pdfs/nc_packet.pdf")
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
end

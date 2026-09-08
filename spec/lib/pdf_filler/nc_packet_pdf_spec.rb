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

  describe "#pdf_fields" do
    subject(:result) { packet_pdf.pdf_fields }

    it "maps the North Carolina-only fields that PacketPdf leaves blank" do
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

    it "delegates operating_homeschool_30_or_more_hours to nc_screener" do
      allow(nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(true)
      expect(result[:operating_homeschool_30_or_more_hours]).to be true
    end

    it "delegates at_least_55_no_diploma_not_working to the state policy" do
      allow(screener.state_policy).to receive(:age_work_education_health_exemption?).and_return(true)
      expect(result[:at_least_55_no_diploma_not_working]).to be true
    end

    it "still maps the fields it inherits from PacketPdf" do
      expect(result[:state]).to eq(LocationData::States::NORTH_CAROLINA)
      expect(result[:birth_date]).to eq("July 13, 1990")
      expect(result[:full_name_with_middle]).to eq("Nigella Lucy Lawson")
    end
  end

  describe "#to_pdf" do
    # Captures the HTML Grover would rasterize, without launching headless Chrome.
    def rendered_html
      html = nil
      allow_any_instance_of(Grover).to receive(:to_pdf) do |instance|
        html = instance.instance_variable_get(:@uri)
        "%PDF-fake"
      end
      yield
      html
    end

    it "shows North Carolina-only fields for a North Carolina screener" do
      nc_screener.teaches_homeschool = "yes"
      nc_screener.homeschool_hours = 20
      nc_screener.homeschool_name = "Small Fry"
      screener.assign_attributes(
        preventing_work_place_to_sleep: "yes",
        preventing_work_drugs_alcohol: "yes",
        preventing_work_domestic_violence: "yes",
        preventing_work_medical_condition: "yes"
      )
      allow(screener.state_policy).to receive(:age_work_education_health_exemption?).and_return(true)

      html = rendered_html { packet_pdf.to_pdf }

      expect(html).to include("I am operating a home school for at least 30 hours a week")
      expect(html).to include("Hours a week operating home school: 20")
      expect(html).to include("Name of the home school: Small Fry")
      expect(html).to include("I do not have a regular place to sleep and shower")
      expect(html).to include("I am struggling with drugs or alcohol")
      expect(html).to include("I am experiencing domestic violence")
      expect(html).to include("I am 55 to 64 years old, I do not have a high school diploma or GED")
    end
  end
end

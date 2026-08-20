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

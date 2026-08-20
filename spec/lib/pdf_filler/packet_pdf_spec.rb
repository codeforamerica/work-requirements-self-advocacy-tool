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
      state: LocationData::States::DELAWARE)
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

    it "omits North Carolina-only fields for a Delaware screener" do
      screener.preventing_work_medical_condition = "yes"

      html = rendered_html { packet_pdf.to_pdf }

      expect(html).not_to include("I am operating a home school")
      expect(html).not_to include("I do not have a regular place to sleep and shower")
      expect(html).not_to include("I am struggling with drugs or alcohol")
      expect(html).not_to include("I am experiencing domestic violence")
      expect(html).not_to include("I am 55 to 64 years old, I do not have a high school diploma or GED")
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

    it "removes a variation selector left orphaned with no emoji attached to it" do
      text = "Hello\u{FE0F} world"
      expect(packet_pdf.strip_emojis(text)).to eq("Hello world")
    end

    it "removes a keycap combiner left orphaned with no digit/emoji attached to it" do
      text = "Hello\u{20E3} world"
      expect(packet_pdf.strip_emojis(text)).to eq("Hello world")
    end
  end
end

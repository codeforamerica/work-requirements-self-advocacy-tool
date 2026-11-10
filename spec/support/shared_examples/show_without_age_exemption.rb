RSpec.shared_examples "a show method that considers age exemption" do |screener_attributes = {}|
  subject { described_class.show?(screener) }

  context "when screener is not exempt due to age" do
    let(:screener) { create(:screener, age_range: "18_to_49", **screener_attributes) }

    it "returns true" do
      expect(described_class.show?(screener)).to eq true
    end
  end

  context "when screener is exempt due to age" do
    let(:screener) { create(:screener, age_range: "65_or_older", **screener_attributes) }

    it "returns false" do
      expect(described_class.show?(screener)).to eq false
    end
  end
end

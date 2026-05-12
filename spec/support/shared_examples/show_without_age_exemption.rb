RSpec.shared_examples "a show method that considers age exemption" do
  subject { described_class.show?(screener) }

  context "when screener is not exempt due to age" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:age).and_return(45)
    end

    it "returns true" do
      expect(described_class.show?(screener)).to eq true
    end
  end

  context "when screener is exempt due to age" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:age).and_return(80)
    end

    it "returns false" do
      expect(described_class.show?(screener)).to eq false
    end
  end
end

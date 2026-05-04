RSpec.shared_examples "show? when screener has no exemption" do
  subject { described_class.show?(screener) }

  context "when screener has an exemption" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:has_exemption?).and_return(true)
    end

    it "returns false" do
      expect(described_class.show?(screener)).to eq false
    end
  end

  context "when screener does not have an exemption" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:has_exemption?).and_return(false)
    end

    it "returns true" do
      expect(described_class.show?(screener)).to eq true
    end
  end
end

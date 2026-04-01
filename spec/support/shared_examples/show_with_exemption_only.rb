RSpec.shared_examples "show? with work rules exemption only" do
  subject { described_class.show?(screener) }

  context "when screener is not exempt from work rules" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
    end

    it "returns false" do
      expect(subject).to eq false
    end
  end

  context "when screener is exempt from work rules" do
    let(:screener) { create(:screener) }

    before do
      allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
    end

    it "returns true" do
      expect(subject).to eq true
    end
  end
end

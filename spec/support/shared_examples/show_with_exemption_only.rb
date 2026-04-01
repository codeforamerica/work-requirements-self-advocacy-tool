RSpec.shared_examples "show? with work rules exemption only" do
  subject { described_class.show?(screener) }

  context "when screener is nil" do
    let(:screener) { nil }

    it "returns false" do
      expect(subject).to eq false
    end
  end

  context "when screener is not exempt from work rules" do
    let(:screener) { instance_double("Screener", exempt_from_work_rules?: false) }

    it "returns false" do
      expect(subject).to eq false
    end
  end

  context "when screener is exempt from work rules" do
    let(:screener) { instance_double("Screener", exempt_from_work_rules?: true) }

    it "returns true" do
      expect(subject).to eq true
    end
  end
end

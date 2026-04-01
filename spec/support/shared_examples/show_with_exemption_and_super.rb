RSpec.shared_examples "show? with work rules exemption and super" do
  context "when screener is nil" do
    let(:screener) { nil }

    it "returns false" do
      expect(subject).to eq false
    end
  end

  context "when screener is not exempt from work rules" do
    let(:screener) { instance_double("Screener", exempt_from_work_rules?: false) }

    it "returns false even if super would return true" do
      set_super_result(true)
      expect(subject).to eq false
    end

    it "returns false if super would return false" do
      set_super_result(false)
      expect(subject).to eq false
    end
  end

  context "when screener is exempt from work rules" do
    let(:screener) { instance_double("Screener", exempt_from_work_rules?: true) }

    it "returns true if super returns true" do
      set_super_result(true)
      expect(subject).to eq true
    end

    it "returns false if super returns false" do
      set_super_result(false)
      expect(subject).to eq false
    end
  end
end

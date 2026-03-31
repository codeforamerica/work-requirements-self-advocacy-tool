describe ".show?" do
  context "when screener is nil" do
    it "returns false" do
      expect(controller.class.show?(nil)).to eq false
    end
  end

  context "when screener is not exempt from work rules" do
    before do
      allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
    end

    it "returns false even if super would return true" do
      expect(controller.class.show?(screener)).to eq false
    end

    it "returns false if super would return false" do
      controller.class.super_result = false
      expect(controller.class.show?(screener)).to eq false
    end
  end

  context "when screener is exempt from work rules" do
    before do
      allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
    end

    it "returns true if super returns true" do
      controller.class.super_result = true
      expect(controller.class.show?(screener)).to eq true
    end

    it "returns false if super returns false" do
      controller.class.super_result = false
      expect(controller.class.show?(screener)).to eq false
    end
  end
end

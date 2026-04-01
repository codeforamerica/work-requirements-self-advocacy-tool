require "rails_helper"

RSpec.describe WorkRulesApplyUnmetController, type: :controller do
  describe ".show?" do
    context "screener without any exemptions" do
      it "returns true" do
        screener = create(:screener, is_working: "no")
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener with an exemption" do
      it "returns true" do
        screener = create(:screener, is_working: "yes", working_hours: "35")
        expect(subject.class.show?(screener)).to eq false
      end
    end
  end
end

require "rails_helper"

RSpec.describe BasicInfoEmailNudgeController, type: :controller do
  describe ".show?" do
    context "screener without email" do
      it "returns true" do
        screener = create(:screener, is_working: "yes")
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener with email" do
      it "returns false " do
        screener = create(:screener, is_working: "yes", email: "email@example.com")
        expect(subject.class.show?(screener)).to eq false
      end
    end
  end
end

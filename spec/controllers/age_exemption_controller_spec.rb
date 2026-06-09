require "rails_helper"

RSpec.describe AgeExemptionController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
    it_behaves_like "saves outcome on edit", expected_outcome: Screener::AGE_EXEMPT
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
  end

  describe ".show?" do
    context "screener is 65 or older" do
      it "returns true" do
        screener = create(:screener, birth_date: 66.years.ago)
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener is under 18" do
      it "returns true" do
        screener = create(:screener, birth_date: 16.years.ago)
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener is within the 18-64 range" do
      it "returns false" do
        screener = create(:screener, birth_date: 30.years.ago)
        expect(subject.class.show?(screener)).to eq false
      end
    end
  end
end

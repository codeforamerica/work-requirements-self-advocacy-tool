require "rails_helper"

RSpec.describe AgeExemptionController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    it_behaves_like "saves outcome on page visit", expected_outcome: Screener::AGE_EXEMPT do
      let(:screener) { create(:screener, :age_exempt) }
    end

    context "with a signed in working-age screener" do
      let(:screener) { create(:screener, age_range: "18_to_49") }

      it_behaves_like "ensure_page_navigable redirects to root", action: :display

      it "does not save an outcome" do
        sign_in screener
        get :display
        expect(screener.reload.outcome).to be_nil
      end
    end
  end

  describe "#show_progress_bar" do
    it "hides the progress bar on the age exemption page" do
      expect(controller.show_progress_bar).to eq(false)
    end
  end

  describe "#show_progress_percentage" do
    it "hides the progress percentage on the age exemption page" do
      expect(controller.show_progress_percentage).to eq(false)
    end
  end

  describe ".show?" do
    %w[under_18 65_or_older].each do |age_range|
      it "returns true for someone in the #{age_range} range, which is outside the 18-64 work requirement age range" do
        screener = create(:screener, age_range: age_range)
        expect(described_class.show?(screener)).to eq(true)
      end
    end

    %w[18_to_49 50_to_54 55_to_64].each do |age_range|
      it "returns false for someone in the #{age_range} range, which is within the 18-64 work requirement age range" do
        screener = create(:screener, age_range: age_range)
        expect(described_class.show?(screener)).to eq(false)
      end
    end

    it "returns false when the age range has not been answered" do
      screener = create(:screener, age_range: "unfilled")
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for someone routed out of state, regardless of age" do
      screener = create(:screener, :age_exempt, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(false)
    end
  end
end

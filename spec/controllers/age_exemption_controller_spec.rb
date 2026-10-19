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
    it "returns true for an age-exempt screener in a supported location" do
      screener = create(:screener)
      allow(screener).to receive(:age_exempt?).and_return(true)

      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false for a screener who is not age exempt" do
      screener = create(:screener)
      allow(screener).to receive(:age_exempt?).and_return(false)

      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for an age-exempt screener routed out of state" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      allow(screener).to receive(:age_exempt?).and_return(true)

      expect(described_class.show?(screener)).to eq(false)
    end
  end
end

require "rails_helper"

RSpec.describe AgeExemptionController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    it_behaves_like "saves outcome on page visit", expected_outcome: Screener::AGE_EXEMPT do
      let(:screener) { create(:screener, :age_exempt) }
    end

    context "with a signed in working-age screener" do
      it "redirects to root without saving an outcome" do
        screener = create(:screener, birth_date: 34.years.ago.to_date)
        sign_in screener

        get :display

        expect(response).to redirect_to(root_path)
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
    it "returns true for someone outside the 18-64 work requirement age range" do
      screener = create(:screener, birth_date: 70.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false for someone within the 18-64 work requirement age range" do
      screener = create(:screener, birth_date: 30.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false when the birth date is unknown" do
      screener = create(:screener, birth_date: nil)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for someone routed out of state, regardless of age" do
      screener = create(:screener, :age_exempt, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(false)
    end
  end
end

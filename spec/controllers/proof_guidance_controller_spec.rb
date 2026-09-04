require "rails_helper"

RSpec.describe ProofGuidanceController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    it "renders for an exempt screener" do
      screener = create(:screener, :with_exemption)
      sign_in screener

      get :display

      expect(response).to be_successful
    end

    it "redirects to root when the screener's state is not listed" do
      screener = create(:screener, :with_exemption, state: LocationData::States::NOT_LISTED)
      sign_in screener

      get :display

      expect(response).to redirect_to(root_path)
    end

    it "redirects to root when the screener is not exempt" do
      screener = create(:screener)
      sign_in screener

      get :display

      expect(response).to redirect_to(root_path)
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

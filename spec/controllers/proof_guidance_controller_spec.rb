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

    context "when the screener's state is not listed" do
      it_behaves_like "ensure_page_navigable redirects to root", action: :display do
        let(:screener) { create(:screener, :with_exemption, state: LocationData::States::NOT_LISTED) }
      end
    end

    context "when the screener is not exempt" do
      it_behaves_like "ensure_page_navigable redirects to root", action: :display do
        let(:screener) { create(:screener) }
      end
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

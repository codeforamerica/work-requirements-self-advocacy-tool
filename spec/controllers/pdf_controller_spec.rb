require "rails_helper"

RSpec.describe PdfController, type: :controller do
  describe "#generate_pdf" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :generate_pdf

    it "sends the combined PDF for an exempt screener" do
      allow_any_instance_of(Screener).to receive(:pdf).and_return("%PDF-1.4 fake pdf")
      screener = create(:screener, :with_exemption)
      sign_in screener

      get :generate_pdf

      expect(response).to be_successful
      expect(response.media_type).to eq("application/pdf")
    end

    it "redirects to root instead of raising when the screener's state is not listed" do
      screener = create(:screener, :with_exemption, state: LocationData::States::NOT_LISTED)
      sign_in screener

      get :generate_pdf

      expect(response).to redirect_to(root_path)
    end

    it "redirects to root when the screener is not exempt" do
      screener = create(:screener)
      sign_in screener

      get :generate_pdf

      expect(response).to redirect_to(root_path)
    end

    it "does not raise for a signed-in, persisted screener" do
      screener = create(:screener, state: LocationData::States::DELAWARE, preventing_work_medical_condition: "yes", current_step: "some_previous_step")
      sign_in screener

      expect { get :generate_pdf }.not_to raise_error
      expect(response).to have_http_status(:success)
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

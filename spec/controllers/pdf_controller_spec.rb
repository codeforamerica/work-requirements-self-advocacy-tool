require "rails_helper"

RSpec.describe PdfController, type: :controller do
  describe "#generate_pdf" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :generate_pdf

    it "renders the PDF for a signed-in, persisted screener" do
      allow_any_instance_of(Grover).to receive(:to_pdf).and_return("%PDF-fake")
      screener = create(:screener, state: LocationData::States::DELAWARE, birth_date: Date.new(1990, 7, 13), preventing_work_medical_condition: "yes", current_step: "some_previous_step")
      sign_in screener

      expect { get :generate_pdf }.not_to raise_error
      expect(response.media_type).to eq("application/pdf")
      expect(response).to have_http_status(:success)
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
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

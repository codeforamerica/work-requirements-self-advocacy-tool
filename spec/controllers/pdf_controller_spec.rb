require "rails_helper"

RSpec.describe PdfController, type: :controller do
  describe "#generate_pdf" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :generate_pdf

    context "with an exempt screener" do
      let(:screener) { create(:screener, :with_exemption, birth_date: 30.years.ago.to_date) }

      before { sign_in screener }

      it "returns a PDF" do
        allow(screener).to receive(:pdf).and_return("%PDF-fake")
        allow(controller).to receive(:current_screener).and_return(screener)

        get :generate_pdf

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to include("application/pdf")
      end
    end

    context "with a non-exempt screener" do
      let(:screener) { create(:screener, birth_date: 30.years.ago.to_date) }

      before { sign_in screener }

      it "redirects to root" do
        get :generate_pdf
        expect(response).to redirect_to(root_path)
      end
    end

    context "with a screener missing a birth_date (skipped flow steps)" do
      let(:screener) { create(:screener, birth_date: nil) }

      before { sign_in screener }

      it "redirects to root without raising an error" do
        expect { get :generate_pdf }.not_to raise_error
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

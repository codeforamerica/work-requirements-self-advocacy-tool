# Usage:
#   it_behaves_like "handles missing screener params", status: :bad_request
#   it_behaves_like "handles missing screener params", status: :unprocessable_content
#
shared_examples "handles missing screener params" do |status:|
  # Default screener; override with a `let(:screener)` block when the page under
  # test only shows for a specific kind of screener.
  let(:screener) { create(:screener) }

  context "with missing screener params" do
    it "returns #{status} and does not raise" do
      sign_in screener

      post :update, params: {}

      expect(response).to have_http_status(status)
    end
  end
end

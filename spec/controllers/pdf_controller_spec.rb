require "rails_helper"

RSpec.describe PdfController, type: :controller do
  describe "#generate_pdf" do
    it "does not raise for a signed-in, persisted screener" do
      screener = create(:screener, state: LocationData::States::DELAWARE, preventing_work_medical_condition: "yes", current_step: "some_previous_step")
      sign_in screener

      expect { get :generate_pdf }.not_to raise_error
      expect(response).to have_http_status(:success)
    end
  end
end

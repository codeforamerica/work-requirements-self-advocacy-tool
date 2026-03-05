require "rails_helper"

RSpec.describe DownloadFormController, type: :controller do
  describe "#email_pdf" do
    let!(:screener) { create(:screener) }

    it "creates an outgoing email sends the email" do
      expect{ get :email_pdf }.to have_enqueued_job(SendOutgoingEmailJob)
    end
  end
end

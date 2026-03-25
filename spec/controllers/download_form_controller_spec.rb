require "rails_helper"

RSpec.describe DownloadFormController, type: :controller do
  describe "#edit" do
    let(:screener) { create(:screener, email: "hi@example.com") }

    before { sign_in screener }

    it "enqueues a SendOutgoingEmailJob if the screener has an email" do
      expect {
        get :edit
      }.to have_enqueued_job(SendOutgoingEmailJob).with(kind_of(Integer))
    end

    it "does not enqueue a job if the screener has no email" do
      screener.update!(email: nil)

      expect {
        get :edit
      }.not_to have_enqueued_job(SendOutgoingEmailJob)
    end
  end
end

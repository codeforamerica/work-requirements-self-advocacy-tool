require "rails_helper"

RSpec.describe DownloadFormController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    context "with signed in screener" do
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

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

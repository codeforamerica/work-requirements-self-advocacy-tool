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

    context "for a DE special_geo zip" do
      render_views
      let(:screener) { create(:screener, :with_exemption, state: "DE", zip_code: "19720", last_name: "Anyone", email: "hi@example.com") }

      before { sign_in screener }

      it "renders one office card per office with subgeography and contact info" do
        get :edit

        expect(response.body).to include("DeLaWarr State Service Center")
        expect(response.body).to include("Churchman")
        expect(response.body).to include("north of I-295")
        expect(response.body).to include("south of I-295")
        expect(response.body).to include("(302) 622-4500")
        expect(response.body).to include("(800) 372-2022")
      end
    end

    context "for a DE single-office zip" do
      render_views
      let(:screener) { create(:screener, :with_exemption, state: "DE", zip_code: "19703", last_name: "Anyone", email: "hi@example.com") }

      before { sign_in screener }

      it "renders a single office with no subgeography heading" do
        get :edit

        expect(response.body).to include("Claymont State Service Center")
        expect(response.body).not_to include("If you live")
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

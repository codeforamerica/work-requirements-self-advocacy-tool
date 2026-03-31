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

  describe ".show?" do
    controller(DownloadFormController) do
      def super_show_result
        true
      end

      def show?(screener)
        !!(screener&.exempt_from_work_rules? && super_show_result)
      end
    end

    subject { controller.show?(screener) }

    def set_super_result(value)
      allow(controller).to receive(:super_show_result).and_return(value)
    end

    let(:screener) { instance_double("Screener") }

    it_behaves_like "show? with work rules exemption"
  end
end

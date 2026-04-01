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
    subject { described_class.show?(screener) }

    context "when screener is exempt from work rules" do
      let(:screener) { instance_double("Screener", exempt_from_work_rules?: true) }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when screener is not exempt from work rules" do
      let(:screener) { instance_double("Screener", exempt_from_work_rules?: false) }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when screener is nil" do
      let(:screener) { nil }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end
end

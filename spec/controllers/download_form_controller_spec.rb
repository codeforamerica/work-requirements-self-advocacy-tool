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

    let(:screener) { instance_double("Screener") }

    before do
      allow(QuestionController).to receive(:show?).and_return(super_result)

      # Only stub if screener exists
      if screener
        allow(screener).to receive(:exempt_from_work_rules?).and_return(exempt)
      end
    end

    context "when exempt and parent allows showing" do
      let(:exempt) { true }
      let(:super_result) { true }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "when exempt is false" do
      let(:exempt) { false }
      let(:super_result) { true }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when parent disallows showing" do
      let(:exempt) { true }
      let(:super_result) { false }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when screener is nil" do
      let(:screener) { nil }
      let(:super_result) { true }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end
end

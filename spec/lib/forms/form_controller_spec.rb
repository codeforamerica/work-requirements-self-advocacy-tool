require "rails_helper"

RSpec.describe Forms::FormController, type: :controller do
  controller(QuestionController) do
    def self.attributes_edited
      [:state, :email]
    end

    def self.model_valid?(model)
      model.state.present?
    end

    def next_path
      root_path
    end
  end

  before do
    routes.draw { post "update" => "anonymous#update" }
    allow(MixpanelService).to receive(:send_event)
    sign_in create(:screener)
  end

  describe "#update" do
    context "when the form is valid" do
      it "fires a page_submit event" do
        post :update, params: {screener: {state: "NC", email: "test@example.com"}}

        expect(MixpanelService).to have_received(:send_event).with(
          hash_including(event_name: "page_submit")
        )
      end

      it "includes non-PII field values directly" do
        post :update, params: {screener: {state: "NC", email: "test@example.com"}}

        expect(MixpanelService).to have_received(:send_event).with(
          hash_including(data: hash_including(state: "NC"))
        )
      end

      it "replaces a present PII value with has_<field>: true" do
        post :update, params: {screener: {state: "NC", email: "test@example.com"}}

        expect(MixpanelService).to have_received(:send_event).with(
          hash_including(data: hash_including(has_email: true))
        )
      end

      it "replaces a blank PII value with has_<field>: false" do
        post :update, params: {screener: {state: "NC", email: ""}}

        expect(MixpanelService).to have_received(:send_event).with(
          hash_including(data: hash_including(has_email: false))
        )
      end
    end

    context "when the form is invalid" do
      it "does not fire a page_submit event" do
        post :update, params: {screener: {state: "", email: "test@example.com"}}

        expect(MixpanelService).not_to have_received(:send_event).with(
          hash_including(event_name: "page_submit")
        )
      end
    end
  end
end

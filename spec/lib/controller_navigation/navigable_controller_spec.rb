require "rails_helper"

RSpec.describe ControllerNavigation::NavigableController do
  describe "#set_item_index", type: :controller do
    controller(ApplicationController) do
      include ControllerNavigation::NavigableController

      def index
        head :ok
      end
    end

    before do
      routes.draw { get "index" => "anonymous#index" }
      allow(subject).to receive(:current_path).and_return(nil)
      sign_in create(:screener)
    end

    context "when item_index is a scalar string" do
      it "sets item_index as an integer" do
        get :index, params: {item_index: "2"}
        expect(controller.item_index).to eq(2)
      end
    end

    context "when item_index is absent" do
      it "sets item_index to nil" do
        get :index
        expect(controller.item_index).to be_nil
      end
    end

    context "when item_index is submitted as an array" do
      it "returns 400 bad request and does not raise" do
        expect { get :index, params: {"item_index" => ["0"]} }.not_to raise_error
        expect(response).to have_http_status(:bad_request)
      end
    end
  end


  describe ".accepts_update?" do
    context "when the controller defines attributes_edited" do
      it "returns true" do
        expect(TribeOrNationController.accepts_update?).to be true
      end
    end

    context "when the controller overrides form_params privately" do
      it "returns true" do
        expect(DateOfBirthController.accepts_update?).to be true
      end
    end

    context "when the controller has neither attributes_edited nor form_params" do
      it "returns false for ProofGuidanceController" do
        expect(ProofGuidanceController.accepts_update?).to be false
      end

      it "returns false for WagesHoursMilestoneController" do
        expect(WagesHoursMilestoneController.accepts_update?).to be false
      end
    end
  end
end

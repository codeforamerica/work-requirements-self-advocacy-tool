require "rails_helper"

RSpec.describe ControllerNavigation::NavigableController do
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

require "rails_helper"

RSpec.describe ControllerNavigation::ControllerNavigation do
  before do
    stub_const("FirstStepController", Class.new)
    stub_const("SecondStepController", Class.new)
    stub_const("UncountedStepController", Class.new)
    stub_const("LastStepController", Class.new)

    stub_const("#{described_class.name}::FLOW", [
      ControllerNavigation::NavigationStep.new(FirstStepController),
      ControllerNavigation::NavigationStep.new(SecondStepController),
      # e.g. the age exemption page, which shouldn't count toward progress
      ControllerNavigation::NavigationStep.new(UncountedStepController, false),
      ControllerNavigation::NavigationStep.new(LastStepController)
    ])
  end

  describe ".controllers" do
    it "returns every controller in the flow, including uncounted steps" do
      expect(described_class.controllers).to eq([
        FirstStepController,
        SecondStepController,
        UncountedStepController,
        LastStepController
      ])
    end
  end

  describe ".pages" do
    it "returns one page per controller in the flow" do
      expect(described_class.pages(nil)).to eq([
        {controller: FirstStepController},
        {controller: SecondStepController},
        {controller: UncountedStepController},
        {controller: LastStepController}
      ])
    end
  end

  describe ".first" do
    it "is the first controller in the flow" do
      expect(described_class.first).to eq(FirstStepController)
    end
  end

  describe ".get_progress_percentage" do
    # There are 3 counted steps (UncountedStepController is excluded), so each
    # counted step is 1/3 of the way through, rounded to the nearest percent.
    it "returns the rounded percentage through the counted steps" do
      expect(described_class.get_progress_percentage(FirstStepController)).to eq(33)
      expect(described_class.get_progress_percentage(SecondStepController)).to eq(67)
    end

    it "returns 100 on the final counted step" do
      expect(described_class.get_progress_percentage(LastStepController)).to eq(100)
    end
  end
end

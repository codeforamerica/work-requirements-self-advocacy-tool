require "rails_helper"

RSpec.describe ControllerNavigation::NavigationStep do
  let(:controller_class) { Class.new }

  describe "#increment_step?" do
    it "increments the step count by default" do
      expect(described_class.new(controller_class).increment_step?).to be_truthy
    end

    it "can be told not to increment the step count" do
      expect(described_class.new(controller_class, false).increment_step?).to be_falsey
    end
  end

  describe "#controllers" do
    it "exposes its controller" do
      expect(described_class.new(controller_class).controllers).to eq([controller_class])
    end
  end

  describe "#pages" do
    it "produces a single page for its controller" do
      expect(described_class.new(controller_class).pages(nil)).to eq([{controller: controller_class}])
    end
  end
end

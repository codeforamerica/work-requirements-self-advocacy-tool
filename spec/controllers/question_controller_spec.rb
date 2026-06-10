require "rails_helper"

RSpec.describe QuestionController, type: :controller do
  describe "#show_progress_bar" do
    it "shows the progress bar by default" do
      expect(controller.show_progress_bar).to eq(true)
    end
  end

  describe "#show_progress_percentage" do
    it "shows the progress percentage by default" do
      expect(controller.show_progress_percentage).to eq(true)
    end
  end

  describe "#percent_complete" do
    it "delegates to the navigation class for the current controller" do
      navigation = class_double(Navigation::ScreenerNavigation)
      allow(controller).to receive(:navigation_class).and_return(navigation)
      allow(navigation).to receive(:get_progress_percentage).with(described_class).and_return(42)

      expect(controller.percent_complete).to eq(42)
    end
  end
end

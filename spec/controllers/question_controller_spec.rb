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

  describe ".show?" do
    it "returns true for a working-age screener in a supported location" do
      screener = create(:screener, birth_date: 30.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false when the birth date is unknown" do
      screener = create(:screener, birth_date: nil)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for a screener under 18" do
      screener = create(:screener, birth_date: 16.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for a screener 65 or older" do
      screener = create(:screener, birth_date: 65.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for a working-age screener whose state is not listed" do
      screener = create(:screener, birth_date: 30.years.ago.to_date, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(false)
    end

    it "returns false for a working-age screener in an unsupported county" do
      screener = create(:screener, birth_date: 30.years.ago.to_date)
      allow(OutOfStateController).to receive(:county_not_supported?).with(screener).and_return(true)
      expect(described_class.show?(screener)).to eq(false)
    end
  end
end

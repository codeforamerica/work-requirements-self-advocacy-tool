require "rails_helper"

RSpec.describe AgeExemptionController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display
    it_behaves_like "saves outcome on display", expected_outcome: Screener::AGE_EXEMPT
  end

  describe "#show_progress_bar" do
    it "hides the progress bar on the age exemption page" do
      expect(controller.show_progress_bar).to eq(false)
    end
  end

  describe "#show_progress_percentage" do
    it "hides the progress percentage on the age exemption page" do
      expect(controller.show_progress_percentage).to eq(false)
    end
  end

  describe ".show?" do
    it "returns true for someone outside the 18-64 work requirement age range" do
      screener = create(:screener, birth_date: 70.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false for someone within the 18-64 work requirement age range" do
      screener = create(:screener, birth_date: 30.years.ago.to_date)
      expect(described_class.show?(screener)).to eq(false)
    end
  end
end

require "rails_helper"

RSpec.describe WorkRulesApplyMetController, type: :controller do
  describe ".show?" do
    let(:screener) { create(:screener) }
    context "screener without exemptions and greater than or equal to 20 hours of volunteer work or training?" do
      before do
        allow(screener).to receive(:no_exemptions_and_greater_than_or_equal_to_20_hours_of_volunteer_work_or_training?).and_return(true)
      end
      it "returns true" do
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener with exemptions and greater than or equal to 20 hours of volunteer work or training?" do
      before do
        allow(screener).to receive(:no_exemptions_and_greater_than_or_equal_to_20_hours_of_volunteer_work_or_training?).and_return(false)
      end
      it "returns false " do
        expect(subject.class.show?(screener)).to eq false
      end
    end
  end
end

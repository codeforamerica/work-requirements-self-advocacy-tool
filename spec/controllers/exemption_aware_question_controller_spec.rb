require "rails_helper"

RSpec.describe ExemptionAwareQuestionController, type: :controller do
  # Minimal subclass so Rails can instantiate the controller
  controller(ExemptionAwareQuestionController) do
    def index
      head :ok
    end
  end

  let(:screener) { create(:screener) }

  describe ".show?" do
    subject { controller.class.show?(screener) }

    context "when screener is exempt from work rules" do
      before { screener.update!(preventing_work_place_to_sleep: "yes") }

      it "returns true if parent allows showing" do
        expect(described_class.show?(screener)).to eq(true)
      end
    end

    context "when screener is not exempt from work rules" do
      before { screener.update!(preventing_work_place_to_sleep: "no") }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end
end

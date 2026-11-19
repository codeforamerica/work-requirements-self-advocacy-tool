require "rails_helper"

RSpec.describe StudentQuestionController, type: :controller do
  controller(StudentQuestionController) do
    def index
      head :ok
    end
  end

  describe ".show?" do
    subject { described_class.show?(screener) }

    let(:screener) { create(:screener, is_student: "yes") }

    context "when screener is a student aged 18 to 49 with no other exemption" do
      it { is_expected.to eq true }

      context "in production" do
        before { allow(Rails.env).to receive(:production?).and_return(true) }

        it { is_expected.to eq false }
      end
    end

    context "when screener is not a student" do
      let(:screener) { create(:screener, is_student: "no") }

      it { is_expected.to eq false }
    end

    context "when screener has another exemption" do
      let(:screener) { create(:screener, is_student: "yes", preventing_work_place_to_sleep: "yes") }

      it { is_expected.to eq false }
    end

    context "when screener has an earnings exemption" do
      let(:screener) { create(:screener, :with_earnings_exemption, is_student: "yes") }

      it { is_expected.to eq false }
    end

    context "when screener is not aged 18 to 49" do
      let(:screener) { create(:screener, is_student: "yes", age_range: "50_to_54") }

      it { is_expected.to eq false }
    end
  end
end

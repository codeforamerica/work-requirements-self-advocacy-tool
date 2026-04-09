require "rails_helper"

RSpec.describe WorkRulesApplyUnmetController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
  end

  describe ".show?" do
    subject(:result) { described_class.show?(screener) }

    context "when screener is not exempt" do
      let(:screener) do
        instance_double("Screener", exempt_from_work_rules?: false)
      end

      it "returns true" do
        expect(result).to be true
      end
    end

    context "when screener is exempt" do
      let(:screener) do
        instance_double("Screener", exempt_from_work_rules?: true)
      end

      it "returns false" do
        expect(result).to be false
      end
    end
  end
end

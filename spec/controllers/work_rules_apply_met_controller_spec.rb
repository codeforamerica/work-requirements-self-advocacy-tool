require "rails_helper"

RSpec.describe WorkRulesApplyMetController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display
    it_behaves_like "saves outcome on display", expected_outcome: Screener::NOT_EXEMPT_WORK_RULES_MET
  end

  describe ".show?" do
    let(:screener) { create(:screener) }

    context "screener without exemptions" do
      before do
        allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
      end

      context "complies with work rules" do
        it "returns true" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(true)

          expect(subject.class.show?(screener)).to eq true
        end
      end

      context "does not comply with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(false)

          expect(subject.class.show?(screener)).to eq false
        end
      end
    end

    context "screener with exemptions" do
      before do
        allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
      end

      context "complies with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(true)

          expect(subject.class.show?(screener)).to eq false
        end
      end

      context "does not comply with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(false)

          expect(subject.class.show?(screener)).to eq false
        end
      end
    end
  end
end

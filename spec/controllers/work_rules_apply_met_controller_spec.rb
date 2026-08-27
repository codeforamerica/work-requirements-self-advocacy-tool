require "rails_helper"

RSpec.describe WorkRulesApplyMetController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    it_behaves_like "saves outcome on page visit", expected_outcome: Screener::NOT_EXEMPT_WORK_RULES_MET do
      let(:screener) { create(:screener, :meets_work_rules) }
    end

    context "with a signed in screener who does not meet the work rules" do
      it "redirects to root without saving an outcome" do
        screener = create(:screener)
        sign_in screener

        get :display

        expect(response).to redirect_to(root_path)
        expect(screener.reload.outcome).to be_nil
      end
    end
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

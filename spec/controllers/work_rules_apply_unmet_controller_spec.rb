require "rails_helper"

RSpec.describe WorkRulesApplyUnmetController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display
    it_behaves_like "saves outcome on page visit", expected_outcome: Screener::NOT_EXEMPT_WORK_RULES_NOT_MET
  end

  describe ".show?" do
    let(:screener) { create(:screener) }

    context "screener without exemptions" do
      before do
        allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
      end

      context "does not comply with work rules" do
        it "returns true" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(false)

          expect(subject.class.show?(screener)).to eq true
        end
      end

      context "complies with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(true)

          expect(subject.class.show?(screener)).to eq false
        end
      end
    end

    context "screener with exemptions" do
      before do
        allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
      end

      context "does not comply with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(false)

          expect(subject.class.show?(screener)).to eq false
        end
      end

      context "complies with work rules" do
        it "returns false" do
          allow(screener).to receive(:complies_with_work_rules?).and_return(true)

          expect(subject.class.show?(screener)).to eq false
        end
      end
    end
  end

  describe "the state-specific time limit text" do
    render_views

    context "when the screener is in NC" do
      it "renders the NC time limit" do
        sign_in create(:screener, state: "NC")

        get :display

        expect(response.body).to include(I18n.t("views.work_rules_apply_unmet.edit.time_limit_text.nc"))
      end
    end

    context "when the screener is in DE" do
      it "renders the DE time limit" do
        sign_in create(:screener, state: "DE")

        get :display

        expect(response.body).to include(I18n.t("views.work_rules_apply_unmet.edit.time_limit_text.de"))
      end
    end
  end
end

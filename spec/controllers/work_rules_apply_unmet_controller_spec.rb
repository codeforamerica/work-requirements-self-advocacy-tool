require "rails_helper"

RSpec.describe WorkRulesApplyUnmetController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
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

  describe "#time_limit_text" do
    context "when the screener is in NC" do
      it "returns the NC-specific translation" do
        screener = build(:screener, state: "NC")
        controller.instance_variable_set(:@current_screener, screener)

        expect(controller.time_limit_text).to eq(I18n.t("views.work_rules_apply_unmet.edit.nc_time_limit_text"))
      end
    end

    context "when the screener is not in NC" do
      it "returns the default translation" do
        screener = build(:screener, state: "DE")
        controller.instance_variable_set(:@current_screener, screener)

        expect(controller.time_limit_text).to eq(I18n.t("views.work_rules_apply_unmet.edit.default_time_limit_text"))
      end
    end
  end
end

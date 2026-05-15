require "rails_helper"

RSpec.describe AlcoholTreatmentProgramController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        is_in_alcohol_treatment_program: "yes",
        alcohol_treatment_program_name: "Prog Ram"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_in_alcohol_treatment_program_yes?).to eq true
      expect(screener.alcohol_treatment_program_name).to eq "Prog Ram"
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end

  describe "#state_notice_text" do
    let(:screener) { create(:screener, state: state) }
    context "when NC" do
      let(:state) { LocationData::States::NORTH_CAROLINA }
      it "returns the translation for NC" do
        controller.instance_variable_set(:@current_screener, screener)
        expect(controller.state_notice_text).to eq(I18n.t("views.alcohol_treatment_program.edit.notice_text_nc"))
      end
    end

    context "when DE" do
      let(:state) {  create(:screener, state: LocationData::States::DELAWARE) }
      it "returns the translation for DE" do
        controller.instance_variable_set(:@current_screener, screener)
        expect(controller.state_notice_text).to eq(I18n.t("views.alcohol_treatment_program.edit.notice_text_de"))
      end
    end
  end
end

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

  describe "the state-specific treatment notice" do
    render_views

    context "when the screener is in NC" do
      it "renders the NC notice (Alcoholics Anonymous only)" do
        sign_in create(:screener, state: LocationData::States::NORTH_CAROLINA)

        get :edit

        expect(response.body).to include(ERB::Util.html_escape(I18n.t("views.alcohol_treatment_program.edit.notice_text.nc")))
        expect(response.body).not_to include("Narcotics Anonymous")
      end
    end

    context "when the screener is in DE" do
      it "renders the DE notice (Alcoholics or Narcotics Anonymous)" do
        sign_in create(:screener, state: LocationData::States::DELAWARE)

        get :edit

        expect(response.body).to include(ERB::Util.html_escape(I18n.t("views.alcohol_treatment_program.edit.notice_text.de")))
      end
    end
  end
end

require "rails_helper"

RSpec.describe BasicInfoCaseNumberController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "saves the case number and redirects to the next step" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {case_number: "ABC-123"}}

      expect(response).to redirect_to subject.next_path
      expect(screener.reload.case_number).to eq "ABC-123"
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end

  describe "the state-specific case number help text" do
    render_views

    context "when the screener is in NC" do
      it "renders the county as the office name and the NC case number labels" do
        sign_in create(:screener, state: "NC", county: "Durham County")

        get :edit

        expect(response.body).to include("Durham County")
        expect(response.body).to include(ERB::Util.html_escape(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label.nc")))
      end
    end

    context "when the screener is not in NC" do
      it "renders the default office name and case number labels" do
        sign_in create(:screener, state: "DE")

        get :edit

        expect(response.body).to include(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.office_name.default"))
        expect(response.body).to include(ERB::Util.html_escape(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label.default")))
      end
    end
  end
end

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

  describe "#case_number_label and #office_name" do
    context "when the screener is in NC" do
      it "returns the NC-specific translation" do
        screener = build(:screener, state: "NC", county: "Durham County")
        controller.instance_variable_set(:@current_screener, screener)

        expect(controller.case_number_label).to eq(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label_nc"))
        expect(controller.office_name).to eq(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.office_name_nc", state: "NC", county: "Durham County"))
      end
    end

    context "when the screener is not in NC" do
      it "returns the default translation" do
        screener = build(:screener, state: "DE")
        controller.instance_variable_set(:@current_screener, screener)

        expect(controller.case_number_label).to eq(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.case_number_label_default"))
        expect(controller.office_name).to eq(I18n.t("views.basic_info_case_number.edit.help_text_county_letter.office_name_default"))
      end
    end
  end
end

require "rails_helper"

RSpec.describe SchoolTypeController, type: :controller do
  let(:screener) { create(:screener, is_student: "yes") }

  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it "checks the option matching the school type already saved on the screener" do
      screener.update!(student_school_type: "trade_tech_school")
      sign_in screener

      get :edit

      expect(response.body).to have_checked_field(I18n.t("views.school_type.edit.trade_tech_school"))
    end
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it_behaves_like "handles missing screener params", status: :bad_request do
      let(:screener) { create(:screener, is_student: "yes") }
    end

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:screener) { create(:screener, is_student: "yes") }
      let(:page_submit_cases) {
        [
          {
            form_params: {student_school_type: "college"},
            expected_data: {student_school_type: "college"}
          }
        ]
      }
    end

    it "saves the selected school type" do
      sign_in screener

      post :update, params: {screener: {student_school_type: "training_program"}}

      expect(screener.reload.student_school_type).to eq "training_program"
    end
  end
end

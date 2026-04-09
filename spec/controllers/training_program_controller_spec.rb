require "rails_helper"

RSpec.describe TrainingProgramController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit


    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        is_in_work_training: "yes",
        work_training_hours: "5",
        work_training_name: "How to do job"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_in_work_training).to eq "yes"
      expect(screener.work_training_hours).to eq "5"
      expect(screener.work_training_name).to eq "How to do job"
    end

    render_views

    it "validation does not allow non-numerical values" do
      screener = create(:screener)
      sign_in screener

      params = {
        is_in_work_training: "yes",
        work_training_hours: "five hours not a number",
        work_training_name: "How to do job"
      }

      post :update, params: {screener: params}
      expect(response).to render_template :edit
      expect(response.body).to have_text(I18n.t("validations.number_invalid"))
    end
  end
end

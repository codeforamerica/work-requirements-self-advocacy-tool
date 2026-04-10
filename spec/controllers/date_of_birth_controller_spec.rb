require "rails_helper"

RSpec.describe DateOfBirthController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it "reads and displays the individual date attributes if birth_date is saved on screener" do
      screener = create(:screener, birth_date: Date.new(1973, 10, 13))
      sign_in screener

      get :edit

      expect(response.body).to have_select("Year", selected: "1973")
      expect(response.body).to have_select("Month", selected: "October")
      expect(response.body).to have_select("Day", selected: "13")
    end
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    context "birth date" do
      it "combines the date picker params into the birth_date attribute" do
        screener = create(:screener)
        sign_in screener

        params = {
          birth_date_month: "10",
          birth_date_day: "13",
          birth_date_year: "1973"
        }

        post :update, params: {screener: params}
        expect(screener.reload.birth_date).to eq Date.new(1973, 10, 13)
      end

      render_views

      it "displays an error if any parameters are is missing" do
        screener = create(:screener)
        sign_in screener

        params = {
          birth_date_month: "5",
          birth_date_day: "3",
          birth_date_year: ""
        }

        post :update, params: {screener: params}
        expect(response).to render_template :edit
        expect(response.body).to have_text I18n.t("validations.date_missing_or_invalid")
      end
    end
  end
end

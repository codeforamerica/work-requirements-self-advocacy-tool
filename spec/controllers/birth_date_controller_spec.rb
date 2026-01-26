require "rails_helper"

RSpec.describe BirthDateController, type: :controller do
  describe "#edit" do
    render_views

    it "reads and displays the individual date attributes if birth_date is saved on screener" do
      create(:screener, birth_date: Date.new(1973, 10, 13))
      get :edit

      expect(response.body).to have_select("Year", selected: "1973")
      expect(response.body).to have_select("Month", selected: "October")
      expect(response.body).to have_select("Day", selected: "13")
    end
  end

  describe "#update" do
    context "birth date" do
      it "combines the date picker params into the birth_date attribute" do
        screener = create(:screener)

        params = {
          birth_date_month: "10",
          birth_date_day: "13",
          birth_date_year: "1973"
        }

        post :update, params: { screener: params }
        expect(screener.reload.birth_date).to eq Date.new(1973, 10, 13)
      end

      render_views

      it "displays an error if parameters are is missing" do
        create(:screener)

        params = {
          birth_date_month: "",
          birth_date_day: "",
          birth_date_year: ""
        }

        post :update, params: { screener: params }
        expect(response).to render_template :edit
        expect(response.body).to have_text "can't be blank"
      end
    end
  end
end

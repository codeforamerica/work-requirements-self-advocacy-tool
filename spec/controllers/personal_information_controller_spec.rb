require "rails_helper"

RSpec.describe PersonalInformationController, type: :controller do
  describe "#edit" do
    context "birth date" do
      render_views

      it "reads and displays the individual date attributes if birth_date is saved on screener" do
        create(:screener, birth_date: Date.new(1973, 10, 13))
        get :edit

        expect(response.body).to have_select("Year", selected: "1973")
        expect(response.body).to have_select("Month", selected: "October")
        expect(response.body).to have_select("Day", selected: "13")
      end
    end
  end

  describe "#update" do
    context "birth date" do
      it "combines the date picker params into the birth_date attribute" do
        screener = create(:screener)

        params = {
          first_name: "Noel",
          middle_name: "G",
          last_name: "Fielding",
          phone_number: "4158161286",
          birth_date_month: "10",
          birth_date_day: "13",
          birth_date_year: "1973"
        }

        post :update, params: {screener: params}
        expect(screener.reload.birth_date).to eq Date.new(1973, 10, 13)
      end
    end
  end
end

require "rails_helper"

RSpec.describe PregnancyController, type: :controller do
  describe "#edit" do
    context "due date" do
      render_views

      it "reads and displays the individual date attributes if pregnancy_due_date is saved on screener" do
        create(:screener, pregnancy_due_date: Date.new(2026, 6, 1))
        get :edit

        expect(response.body).to have_select("Year", selected: "2026")
        expect(response.body).to have_select("Month", selected: "June")
        expect(response.body).to have_select("Day", selected: "1")
      end
    end
  end

  describe "#update" do
    context "due date" do
      it "ignores the due date parameters when the answer is no" do
        screener = create(:screener)

        params = {
          is_pregnant: "no",
          pregnancy_due_date_month: "6",
          pregnancy_due_date_day: "1",
          pregnancy_due_date_year: "2026"
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.is_pregnant_no?).to eq true
        expect(screener.reload.pregnancy_due_date).to be_nil
      end

      it "combines the date picker params into the pregnancy_due_date attribute" do
        screener = create(:screener)

        params = {
          is_pregnant: "yes",
          pregnancy_due_date_month: "6",
          pregnancy_due_date_day: "1",
          pregnancy_due_date_year: "2026"
        }

        post :update, params: {screener: params}
        expect(screener.reload.pregnancy_due_date).to eq Date.new(2026, 6, 1)
      end

      it "does not save the date when any date params are missing" do
        screener = create(:screener)
        params = {
          is_pregnant: "yes",
          pregnancy_due_date_month: "10",
          pregnancy_due_date_day: "2",
          pregnancy_due_date_year: ""
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.pregnancy_due_date).to be_nil
      end

      it "accepts empty date params" do
        screener = create(:screener)
        params = {
          is_pregnant: "yes",
          pregnancy_due_date_month: "",
          pregnancy_due_date_day: "",
          pregnancy_due_date_year: ""
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.pregnancy_due_date).to be_nil
      end
    end
  end
end

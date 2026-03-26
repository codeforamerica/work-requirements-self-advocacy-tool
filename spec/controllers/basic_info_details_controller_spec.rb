require "rails_helper"

RSpec.describe BasicInfoDetailsController, type: :controller do
  describe "#update" do
    it "persists attributes to the screener" do
      screener = create(:screener, birth_date: Date.new(1990, 1, 1))
      sign_in screener

      params = {
        first_name: "Noel",
        middle_name: "G",
        last_name: "Fielding",
        phone_number: "4158161286",
        consented_to_texts: "yes",
        birth_date_month: "10",
        birth_date_day: "13",
        birth_date_year: "1973"
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      screener.reload
      expect(screener.first_name).to eq "Noel"
      expect(screener.middle_name).to eq "G"
      expect(screener.last_name).to eq "Fielding"
      expect(screener.phone_number).to eq "(415) 816-1286"
      expect(screener.consented_to_texts_yes?).to eq true
      expect(screener.birth_date).to eq Date.new(1973, 10, 13)
    end

    it "does not persist and shows error when birth date is incomplete" do
      screener = create(:screener, birth_date: Date.new(1990, 1, 1))
      sign_in screener

      params = {
        first_name: "Noel",
        middle_name: "G",
        last_name: "Fielding",
        phone_number: "4158161286",
        consented_to_texts: "yes",
        birth_date_month: "",   # missing month
        birth_date_day: "13",
        birth_date_year: "1973"
      }

      post :update, params: { screener: params }
      expect(response).to render_template(:edit)
      screener.reload

      expect(screener.birth_date).to eq Date.new(1990, 1, 1)
      expect(assigns(:model).errors[:birth_date]).to include(I18n.t("validations.date_missing_or_invalid"))
    end
  end
end

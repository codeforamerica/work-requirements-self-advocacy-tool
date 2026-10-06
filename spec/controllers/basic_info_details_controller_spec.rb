require "rails_helper"

RSpec.describe BasicInfoDetailsController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
    it_behaves_like "rejects invalid enum values", fields: [:consented_to_texts], screener_factory: -> { create(:screener, :with_exemption) }

    it_behaves_like "handles missing screener params", status: :bad_request do
      let(:screener) { create(:screener, :with_exemption) }
    end

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:screener) { create(:screener, :with_exemption) }
      let(:page_submit_cases) do
        [{
          form_params: {
            first_name: "Noel",
            middle_name: "G",
            last_name: "Fielding",
            phone_number: "4158161286",
            consented_to_texts: "yes",
            birth_date_month: "10",
            birth_date_day: "13",
            birth_date_year: "1973"
          },
          expected_data: {
            has_first_name: true,
            has_middle_name: true,
            has_last_name: true,
            has_phone_number: true,
            consented_to_texts: "yes",
            has_birth_date: true
          }
        }]
      end
      let(:invalid_params) do
        {
          first_name: "Noel",
          middle_name: "G",
          last_name: "Fielding",
          phone_number: "4158161286",
          consented_to_texts: "yes",
          birth_date_month: "",
          birth_date_day: "13",
          birth_date_year: "1973"
        }
      end
    end

    it "persists attributes to the screener" do
      screener = create(:screener, :with_exemption, birth_date: Date.new(1990, 1, 1))
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
      screener = create(:screener, :with_exemption, birth_date: Date.new(1990, 1, 1))
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

      post :update, params: {screener: params}
      expect(response).to render_template(:edit)
      screener.reload

      expect(screener.birth_date).to eq Date.new(1990, 1, 1)
      expect(assigns(:model).errors[:birth_date]).to include(I18n.t("validations.date_missing_or_invalid"))
    end

    [
      {description: "a day that doesn't exist in the month", month: "2", day: "30", year: "1990"},
      {description: "a non-numeric day", month: "2", day: "1a", year: "1990"},
      {description: "a year that isn't 4 digits", month: "2", day: "1", year: "199"},
      {description: "a future year", month: "2", day: "1", year: (Date.current.year + 1).to_s}
    ].each do |date_params|
      it "does not persist and keeps the entered values when birth date has #{date_params[:description]}" do
        screener = create(:screener, :with_exemption, birth_date: Date.new(1990, 1, 1))
        sign_in screener

        params = {
          first_name: "Noel",
          last_name: "Fielding",
          birth_date_month: date_params[:month],
          birth_date_day: date_params[:day],
          birth_date_year: date_params[:year]
        }

        post :update, params: {screener: params}
        expect(response).to render_template(:edit)
        expect(screener.reload.birth_date).to eq Date.new(1990, 1, 1)

        model = assigns(:model)
        expect(model.errors[:birth_date]).to include(I18n.t("validations.date_missing_or_invalid"))
        expect([model.birth_date_month, model.birth_date_day, model.birth_date_year]).to eq date_params.values_at(:month, :day, :year)
      end
    end
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

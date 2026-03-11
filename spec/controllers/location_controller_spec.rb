require "rails_helper"

RSpec.describe LocationController, type: :controller do
  describe "#edit" do
    render_views

    it "reads and displays the state and county attributes if they are saved on screener" do
      screener = create(:screener, state: "NC", county: "Anson County")
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "North Carolina")
      expect(response.body).to include("Anson County")
    end

    it "reads and displays the state attribute if it is saved on screener" do
      screener = create(:screener, state: "NOT_LISTED")
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "It's not listed here")
    end
  end

  describe "#update" do
    context "location" do
      it "updates the state and county values" do
        screener = create(:screener)
        sign_in screener

        params = {
          state: "NC",
          county: "Anson County"
        }

        post :update, params: {screener: params}
        expect(screener.reload.state).to eq "NC"
        expect(screener.reload.county).to eq "Anson County"

        params = {
          state: "NOT_LISTED"
        }

        post :update, params: {screener: params}
        expect(screener.reload.state).to eq "NOT_LISTED"
        expect(screener.reload.county).to be_nil
      end
    end
  end
end

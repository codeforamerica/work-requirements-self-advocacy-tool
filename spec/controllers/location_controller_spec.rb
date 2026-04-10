require "rails_helper"

RSpec.describe LocationController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

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
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

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

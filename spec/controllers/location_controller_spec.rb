require "rails_helper"

RSpec.describe LocationController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it "reads and displays the state and county attributes if they are saved on the screener" do
      screener = create(:screener, state: "NC", county: "Anson County")
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "North Carolina")
      expect(response.body).to include("Anson County")
    end

    it "reads and displays the state and zip code attributes if they are saved on the screener" do
      screener = create(:screener, state: "DE", zip_code: "19954")
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "Delaware")
      expect(response.body).to include("19954")
    end

    it "reads and displays unlisted state attribute if it is saved on the screener" do
      screener = create(:screener, state: "NOT_LISTED")
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "It's not listed here")
    end

    it "returns 400 when item_index is submitted as an array" do
      screener = create(:screener)
      sign_in screener

      get :edit, params: {item_index: ["1"]}

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "updates the state and county values and sends a mixpanel event" do
      screener = create(:screener)
      sign_in screener
      allow(MixpanelService).to receive(:send_event)

      params = {
        state: "NC",
        county: "Anson County"
      }

      post :update, params: {screener: params}
      expect(screener.reload.state).to eq "NC"
      expect(screener.reload.county).to eq "Anson County"

      expect(MixpanelService).to have_received(:send_event).with(
        hash_including(
          event_name: "page_submit",
          data: {state: "NC", county: "Anson County"}
        )
      )
    end

    it "updates the state and zip code values and sends a mixpanel event" do
      screener = create(:screener)
      sign_in screener
      allow(MixpanelService).to receive(:send_event)

      params = {
        state: "DE",
        zip_code: "19954"
      }

      post :update, params: {screener: params}
      expect(screener.reload.state).to eq "DE"
      expect(screener.reload.zip_code).to eq "19954"

      expect(MixpanelService).to have_received(:send_event).with(
        hash_including(
          event_name: "page_submit",
          data: {state: "DE", zip_code: "19954"}
        )
      )
    end

    it "redirects successfully when item_index=0 is passed as a query param" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {state: "NC", county: "Anson County"}, item_index: "0"}

      expect(response).to have_http_status(:redirect)
    end

    it "redirects successfully when return_to_review=1 is passed as a query param" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {state: "NC", county: "Anson County"}, return_to_review: "1"}

      expect(response).to have_http_status(:redirect)
    end
  end
end

require "rails_helper"

RSpec.describe LocationController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it "reads and displays the state, county, receives_snap attributes if they are saved on the screener" do
      screener = create(:screener, state: "NC", county: "Anson County", receives_snap: :applied_waiting)
      sign_in screener
      get :edit

      expect(response.body).to have_select("screener_state", selected: "North Carolina")
      expect(response.body).to include("Anson County")
      expect(response.body).to have_checked_field("screener_receives_snap_applied_waiting")
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
    it_behaves_like :session_must_be_active_for_this_post_action, action: :update

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) {
        [
          {
            form_params: {state: "NC", county: "Anson County", receives_snap: "yes"},
            expected_data: {state: "NC", has_county: true, receives_snap: "yes"}
          },
          {
            form_params: {state: "DE", zip_code: "19954", receives_snap: "applied_waiting"},
            expected_data: {state: "DE", has_zip_code: true, receives_snap: "applied_waiting"}
          }
        ]
      }
      let(:invalid_params) { {state: ""} }
    end

    it "updates the state and county values" do
      screener = create(:screener)
      sign_in screener

      params = {
        state: "NC",
        county: "Anson County",
        receives_snap: "yes"
      }

      post :update, params: {screener: params}
      expect(screener.reload.state).to eq "NC"
      expect(screener.reload.county).to eq "Anson County"
      expect(screener.reload.receives_snap).to eq "yes"
    end

    it "updates the state and zip code values" do
      screener = create(:screener)
      sign_in screener
      params = {
        state: "DE",
        zip_code: "19954",
        receives_snap: "no"
      }

      post :update, params: {screener: params}
      expect(screener.reload.state).to eq "DE"
      expect(screener.reload.zip_code).to eq "19954"
      expect(screener.reload.receives_snap).to eq "no"
    end

    it "redirects successfully when item_index=0 is passed as a query param" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {state: "NC", county: "Anson County", receives_snap: "no"}, item_index: "0"}

      expect(response).to have_http_status(:redirect)
    end

    it "redirects successfully when return_to_review=1 is passed as a query param" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: {state: "NC", county: "Anson County", receives_snap: "no"}, return_to_review: "1"}

      expect(response).to have_http_status(:redirect)
    end

    it "returns 422 when receives_snap is not a valid option" do
      screener = create(:screener)
      sign_in screener

      post :update, params: { screener: {state: "NC", county: "Anson County", receives_snap: "maybe"} }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

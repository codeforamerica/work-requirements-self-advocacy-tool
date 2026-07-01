require "rails_helper"

RSpec.describe TribeOrNationController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    let(:params) { {is_american_indian: "no"} }
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
    it_behaves_like :session_must_be_active_for_this_post_action, action: :update
    it_behaves_like "rejects invalid enum values", fields: [:is_american_indian]
    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) do
        [{
          form_params: params,
          expected_data: params
        }]
      end
      let(:invalid_params) { {is_american_indian: ""} }
    end

    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_american_indian).to eq "no"
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end
end

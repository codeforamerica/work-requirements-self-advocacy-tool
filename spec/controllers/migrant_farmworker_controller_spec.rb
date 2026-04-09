require "rails_helper"

RSpec.describe MigrantFarmworkerController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit


    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      params = {
        is_migrant_farmworker: "no"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_migrant_farmworker).to eq "no"
    end
  end
end

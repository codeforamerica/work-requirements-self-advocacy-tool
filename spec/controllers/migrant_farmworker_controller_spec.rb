require "rails_helper"

RSpec.describe MigrantFarmworkerController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        is_migrant_farmworker: "yes"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.is_migrant_farmworker).to eq "yes"
    end
  end
end

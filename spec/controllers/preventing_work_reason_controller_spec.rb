require "rails_helper"

RSpec.describe PreventingWorkReasonController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        preventing_work_additional_info: "This is my very good reason"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.preventing_work_additional_info).to eq "This is my very good reason"
    end
  end
end

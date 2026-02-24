require "rails_helper"

RSpec.describe PreventingWorkDetailsController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        preventing_work_additional_info: "This is my very good reason",
        preventing_work_place_to_sleep: "no"
      }

      post :update, params: {screener: params}
      screener.reload
      expect(screener.preventing_work_additional_info).to eq "This is my very good reason"
    end
  end

  # describe ".show?" do
  #   context "screener without conditions" do
  #     it "returns false" do
  #       screener = create(:screener)
  #       expect(subject.class.show?(screener)).to eq false
  #     end
  #   end
  #
  #   context "screener with conditions" do
  #     it "returns true " do
  #       screener = create(:screener, preventing_work_place_to_sleep: "yes")
  #       expect(subject.class.show?(screener)).to eq true
  #     end
  #   end
  # end
end

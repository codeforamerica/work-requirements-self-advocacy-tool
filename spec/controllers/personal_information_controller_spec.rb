require "rails_helper"

RSpec.describe PersonalInformationController, type: :controller do
  describe "#update" do
    it "persists attributes to the screener" do
      screener = create(:screener)

      params = {
        first_name: "Noel",
        middle_name: "G",
        last_name: "Fielding",
        phone_number: "4158161286"
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      expect(screener.reload.first_name).to eq "Noel"
      expect(screener.reload.middle_name).to eq "G"
      expect(screener.reload.last_name).to eq "Fielding"
      expect(screener.reload.phone_number).to eq "(415) 816-1286"
    end
  end
end

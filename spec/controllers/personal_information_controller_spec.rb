require "rails_helper"

RSpec.describe PersonalInformationController, type: :controller do
  describe "#update" do
    it "persists attributes to the screener" do
      screener = create(:screener)

      params = {
        first_name: "Noel",
        middle_name: "G",
        last_name: "Fielding",
        phone_number: "4158161286",
        consented_to_texts: "yes"
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      screener.reload
      expect(screener.first_name).to eq "Noel"
      expect(screener.middle_name).to eq "G"
      expect(screener.last_name).to eq "Fielding"
      expect(screener.phone_number).to eq "(415) 816-1286"
      expect(screener.consented_to_texts_yes?).to eq true
    end
  end
end

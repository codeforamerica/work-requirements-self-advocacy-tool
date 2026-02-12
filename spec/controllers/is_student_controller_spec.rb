require "rails_helper"

RSpec.describe IsStudentController, type: :controller do
  describe "#update" do
    context "when the answer is no" do
      it "persists the values to the current screener" do
        screener = create(:screener)

        params = {
          is_student: "no"
        }

        post :update, params: {screener: params}
        screener.reload
        expect(screener.is_student).to eq "no"
      end
    end
  end
end

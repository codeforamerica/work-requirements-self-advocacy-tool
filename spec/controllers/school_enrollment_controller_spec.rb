require "rails_helper"

RSpec.describe SchoolEnrollmentController, type: :controller do
  describe "#update" do
    context "when the answer is no" do
      it "persists the values to the current screener" do
        screener = create(:screener, birth_date: 55.years.ago.to_date)
        sign_in screener

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

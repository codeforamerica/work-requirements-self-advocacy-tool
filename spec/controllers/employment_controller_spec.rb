require "rails_helper"

RSpec.describe EmploymentController, type: :controller do
  describe "#update" do
    it "persists the values to the current screener" do
      screener = create(:screener)

      params = {
        is_working: "yes",
        working_hours: 20,
        working_weekly_earnings: 300.40
      }

      post :update, params: {screener: params}
      expect(response).to redirect_to subject.next_path
      expect(screener.reload.is_working_yes?).to eq true
      expect(screener.reload.working_hours).to eq 20
      expect(screener.reload.working_weekly_earnings).to eq 300.40
    end
  end
end

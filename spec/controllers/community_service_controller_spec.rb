require "rails_helper"

RSpec.describe CommunityServiceController, type: :controller do
  describe "#update" do
    context "volunteering hours and organization" do
      it "ignores the volunteering hours and org when the answer is no" do
        screener = create(:screener)

        params = {
          is_volunteer: "no"
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.is_volunteer_no?).to eq true
      end

      it "saves the volunteering hours and org when the answer is yes" do
        screener = create(:screener)

        params = {
          is_volunteer: "yes",
          volunt: "6",
          volunteering_hours: "1",
          volunteering_org_name: "cfa"
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.is_volunteer_yes?).to eq true
        expect(screener.reload.volunteering_hours).to eq 1
        expect(screener.reload.volunteering_org_name).to eq "cfa"
      end
    end
  end
end

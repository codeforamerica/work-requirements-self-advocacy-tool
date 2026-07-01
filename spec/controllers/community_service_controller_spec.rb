require "rails_helper"

RSpec.describe CommunityServiceController, type: :controller do
  describe ".show?" do
    it_behaves_like "show? when screener has no exemption"
  end

  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
    it_behaves_like "rejects invalid enum values", fields: [:is_volunteer]

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) do
        params = {is_volunteer: "yes", volunteering_hours: "1", volunteering_org_name: "cfa"}
        [{form_params: params, expected_data: params}]
      end
      let(:invalid_params) { {is_volunteer: "yes", volunteering_hours: "not a valid number", volunteering_org_name: "cfa"} }
    end

    context "volunteering hours and organization" do
      it "ignores the volunteering hours and org when the answer is no" do
        screener = create(:screener)
        sign_in screener

        params = {
          is_volunteer: "no"
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to subject.next_path
        expect(screener.reload.is_volunteer_no?).to eq true
      end

      it "saves the volunteering hours and org when the answer is yes" do
        screener = create(:screener)
        sign_in screener

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

      render_views

      it "validation does not allow non-numerical values" do
        screener = create(:screener)
        sign_in screener

        params = {
          is_volunteer: "yes",
          volunt: "6",
          volunteering_hours: "not a valid number",
          volunteering_org_name: "cfa"
        }

        post :update, params: {screener: params}
        expect(response).to render_template :edit
        expect(response.body).to have_text(I18n.t("validations.number_invalid"))
      end
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end
end

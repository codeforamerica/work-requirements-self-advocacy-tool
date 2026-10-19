require "rails_helper"

RSpec.describe AgeRangeController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it_behaves_like "ensure_page_navigable redirects to root", action: :edit do
      let(:screener) { create(:screener, state: LocationData::States::NOT_LISTED) }
    end

    it "checks the option matching the age range already saved on the screener" do
      screener = create(:screener, age_range: "50_to_54")
      sign_in screener

      get :edit

      expect(response.body).to have_checked_field(I18n.t("views.age_range.edit.age_50_to_54"))
    end
  end

  describe "#show_progress_bar" do
    it "hides the progress bar on the age range page" do
      expect(controller.show_progress_bar).to eq(false)
    end
  end

  describe ".show?" do
    it "returns true for a screener in a supported location, even without an age range" do
      screener = create(:screener, age_range: "unfilled")
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns true for a screener who is age exempt, so they can change their answer" do
      screener = create(:screener, :age_exempt)
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false for a screener routed out of state" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(false)
    end
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it_behaves_like "handles missing screener params", status: :bad_request

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) {
        [
          {
            form_params: {age_range: "55_to_64"},
            expected_data: {age_range: "55_to_64"}
          }
        ]
      }
      let(:invalid_params) { {age_range: "unfilled"} }
    end

    it "saves the selected age range" do
      screener = create(:screener, age_range: "unfilled")
      sign_in screener

      post :update, params: {screener: {age_range: "65_or_older"}}

      expect(screener.reload.age_range).to eq "65_or_older"
    end

    render_views

    it "displays an error if no age range is selected" do
      screener = create(:screener, age_range: "unfilled")
      sign_in screener

      post :update, params: {screener: {age_range: "unfilled"}}

      expect(response).to render_template :edit
      expect(response.body).to have_text I18n.t("validations.age_range_required")
    end
  end
end

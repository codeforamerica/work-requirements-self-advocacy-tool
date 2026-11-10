require "rails_helper"

RSpec.describe LivingWithChildExemptionController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    context "with a screener who is getting SNAP" do
      render_views

      it "shows the receiving SNAP content" do
        sign_in create(:screener, has_child: "yes", receives_snap: "yes")

        get :display

        expect(response.body).to include(I18n.t("views.living_with_child_exemption.edit.receiving.callout_title"))
        expect(response.body).not_to include(I18n.t("views.living_with_child_exemption.edit.pending.callout_title"))
      end
    end

    context "with a screener whose application is pending" do
      render_views

      it "shows the pending application content" do
        sign_in create(:screener, has_child: "yes", receives_snap: "applied_waiting")

        get :display

        expect(response.body).to include(I18n.t("views.living_with_child_exemption.edit.pending.callout_title"))
        expect(response.body).not_to include(I18n.t("views.living_with_child_exemption.edit.receiving.callout_title"))
      end
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption", {has_child: "yes", receives_snap: "yes"}
  end
end

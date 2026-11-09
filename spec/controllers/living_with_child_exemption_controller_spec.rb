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
    it "does not show for an age-exempt screener" do
      screener = create(:screener, age_range: "65_or_older", has_child: "yes", receives_snap: "yes")
      expect(described_class.show?(screener)).to eq false
    end

    [LocationData::States::DELAWARE, LocationData::States::NORTH_CAROLINA].each do |state|
      context "in #{state}" do
        it "shows when the screener lives with a child and is getting SNAP" do
          screener = create(:screener, state: state, has_child: "yes", receives_snap: "yes")
          expect(described_class.show?(screener)).to eq true
        end

        it "shows when the screener lives with a child and their application is pending" do
          screener = create(:screener, state: state, has_child: "yes", receives_snap: "applied_waiting")
          expect(described_class.show?(screener)).to eq true
        end

        it "does not show when the screener is not getting SNAP" do
          screener = create(:screener, state: state, has_child: "yes", receives_snap: "no")
          expect(described_class.show?(screener)).to eq false
        end

        it "does not show when the screener does not live with a child" do
          screener = create(:screener, state: state, has_child: "no", receives_snap: "yes")
          expect(described_class.show?(screener)).to eq false
        end
      end
    end
  end
end

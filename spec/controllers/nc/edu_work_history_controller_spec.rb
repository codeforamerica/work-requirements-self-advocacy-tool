require "rails_helper"

RSpec.describe Nc::EduWorkHistoryController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it_behaves_like "rejects invalid enum values",
      fields: [:has_hs_diploma, :worked_last_five_years, :earned_more_than_threshold, :health_conditions_preventing_work],
      params_key: :nc_screener,
      screener_factory: -> {
        s = create(:screener, state: "NC")
        s.create_nc_screener
        s
      }

    it_behaves_like "a controller where update fires a page_submit Mixpanel event", {nc_screener: true} do
      let(:page_submit_cases) do
        params = {
          has_hs_diploma: "no",
          worked_last_five_years: "yes",
          earned_more_than_threshold: "no",
          health_conditions_preventing_work: "no"
        }
        [
          {
            form_params: params,
            expected_data: params
          }
        ]
      end
    end

    it "persists the values to the nc_screener" do
      screener = create(:screener, state: "NC")
      screener.create_nc_screener
      sign_in screener

      params = {
        has_hs_diploma: "no",
        worked_last_five_years: "yes",
        earned_more_than_threshold: "no",
        health_conditions_preventing_work: "no"
      }

      post :update, params: {nc_screener: params}
      screener.nc_screener.reload
      expect(screener.nc_screener.has_hs_diploma).to eq "no"
      expect(screener.nc_screener.worked_last_five_years).to eq "yes"
      expect(screener.nc_screener.earned_more_than_threshold).to eq "no"
      expect(screener.nc_screener.health_conditions_preventing_work).to eq "no"
    end
  end

  describe ".show?" do
    context "screener with NC" do
      it "returns false" do
        screener = create(:screener, state: "NC", birth_date: 30.years.ago.to_date)
        expect(subject.class.show?(screener)).to eq false
      end

      it "returns true" do
        screener = create(:screener, state: "NC", birth_date: 55.years.ago.to_date)
        expect(subject.class.show?(screener)).to eq true
      end
    end

    context "screener with !NC" do
      it "returns false" do
        screener = create(:screener, state: "TX", birth_date: 30.years.ago.to_date)
        expect(subject.class.show?(screener)).to eq false
      end

      it "returns false" do
        screener = create(:screener, state: "TX", birth_date: 55.years.ago.to_date)
        expect(subject.class.show?(screener)).to eq false
      end
    end
  end
end

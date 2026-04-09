require "rails_helper"

RSpec.describe Nc::EduWorkHistoryController, type: :controller do
  describe "#update" do
    it "persists the values to the nc_screener" do
      screener = create(:screener, state: "NC")
      screener.create_nc_screener
      sign_in screener

      params = {
        has_hs_diploma: "no",
        worked_last_five_years: "yes"
      }

      post :update, params: {nc_screener: params}
      screener.nc_screener.reload
      expect(screener.nc_screener.has_hs_diploma).to eq "no"
      expect(screener.nc_screener.worked_last_five_years).to eq "yes"
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

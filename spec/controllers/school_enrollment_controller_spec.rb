require "rails_helper"

RSpec.describe SchoolEnrollmentController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    context "when the answer is no" do
      it "persists the values to the current screener" do
        screener = create(:screener)
        sign_in screener

        params = {
          is_student: "no"
        }

        post :update, params: {screener: params}
        screener.reload
        expect(screener.is_student).to eq "no"
      end
    end

    context "when the state is not North Carolina" do
      it "persists school_type" do
        screener = create(:screener, state: LocationData::States::DELAWARE)
        sign_in screener

        params = {
          is_student: "yes",
          school_type: "college_or_trade_school"
        }

        post :update, params: {screener: params}
        screener.reload
        expect(screener.school_type).to eq "college_or_trade_school"
      end
    end

    context "when the state is North Carolina" do
      it "does not persist school_type (college or trade school)" do
        screener = create(:screener, state: LocationData::States::NORTH_CAROLINA)
        sign_in screener

        params = {
          is_student: "yes",
          school_type: "college_or_trade_school"
        }

        post :update, params: {screener: params}
        screener.reload
        expect(screener.school_type).to be_nil
      end

      it "does not persist school_type (high school or GED)" do
        screener = create(:screener, state: LocationData::States::NORTH_CAROLINA)
        sign_in screener

        params = {
          is_student: "yes",
          school_type: "high_school_or_ged"
        }

        post :update, params: {screener: params}
        screener.reload
        expect(screener.school_type).to be_nil
      end
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end
end

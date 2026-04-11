require "rails_helper"

RSpec.describe SignatureController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit

    it "persists signature to the current screener and sets signed_at to the current time" do
      screener = create(:screener)
      sign_in screener

      params = {
        signature: "Rahul Mandal"
      }

      frozen_time = DateTime.new(2026, 1, 9)
      travel_to frozen_time do
        post :update, params: { screener: params }
        screener.reload
        expect(screener.signature).to eq "Rahul Mandal"
        expect(screener.signed_at).to eq(frozen_time)
      end
    end
  end
end

require "rails_helper"

RSpec.describe ErrorsController, type: :controller do
  describe "locale resolution" do
    context "when the screener has a locale set" do
      it "does not overwrite it during error handling" do
        screener = create(:screener, locale: "es")
        sign_in screener
        get :not_found
        expect(screener.reload.locale).to eq("es")
      end
    end
  end
end

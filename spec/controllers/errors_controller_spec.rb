require "rails_helper"

RSpec.describe ErrorsController, type: :controller do
  describe "#screener_locale" do
    context "when the screener has a locale set" do
      it "does not overwrite it during error handling" do
        screener = create(:screener, locale: "es")
        sign_in screener
        get :not_found
        expect(screener.reload.locale).to eq("es")
      end
    end

    context "when ActiveRecord::ConnectionNotEstablished is raised" do
      it "returns nil" do
        get :not_found
        allow(controller).to receive(:current_screener).and_raise(ActiveRecord::ConnectionNotEstablished)
        expect(controller.send(:screener_locale)).to be_nil
      end
    end

    context "when ActiveRecord::StatementInvalid is raised" do
      it "returns nil" do
        get :not_found
        allow(controller).to receive(:current_screener).and_raise(ActiveRecord::StatementInvalid)
        expect(controller.send(:screener_locale)).to be_nil
      end
    end
  end
end

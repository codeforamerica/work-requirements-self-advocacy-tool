require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      respond_to do |format|
        format.html { head :ok }
        format.js { head :ok }
      end
    end

    def create
      head :ok
    end
  end

  describe "#switch_locale" do
    let(:language) { "es" }
    let(:available_locales) { ["es", "en"] }

    before do
      allow(I18n).to receive(:with_locale).and_call_original
      allow(I18n).to receive(:default_locale).and_return("en")
      allow(I18n).to receive(:available_locales).and_return(available_locales)
    end

    context "locale is in params" do
      it "uses the locale from params" do
        get :index, params: {locale: "es"}

        expect(I18n).to have_received(:with_locale).with("es", any_args)
      end
    end

    context "no locale in params" do
      it "uses the default locale" do
        get :index, params: {}

        expect(I18n).to have_received(:with_locale).with("en", any_args)
      end
    end
  end

  describe "#set_visitor_id" do
    context "existing visitor_id" do
      context "on current_screener" do
        let(:screener) { create :screener, visitor_id: "123" }

        before do
          allow(subject).to receive(:current_screener).and_return(screener)
        end

        it "gets the visitor id from the intake and sets it in the cookies" do
          get :index

          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end

      context "on cookie" do
        before do
          cookies.encrypted[:visitor_id] = "123"
        end

        it "retains the existing visitor id" do
          get :index

          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end

      context "on current_screener AND cookie" do
        let(:screener) { create :screener, visitor_id: "123" }

        before do
          allow(subject).to receive(:current_screener).and_return(screener)
          cookies.encrypted[:visitor_id] = "456"
        end

        it "gets the visitor id from the screener and sets it in the cookie" do
          get :index

          expect(screener.visitor_id).to eq "123"
          expect(cookies.encrypted[:visitor_id]).to eq "123"
        end
      end
    end

    context "no visitor id" do
      it "generates and sets a visitor id cookie" do
        get :index
        expect(cookies.encrypted[:visitor_id]).to be_a String
        expect(cookies.encrypted[:visitor_id]).to be_present
      end

      context "with current screener" do
        let(:screener) { create :screener }

        before do
          allow(subject).to receive(:current_screener).and_return(screener)
        end

        it "saves the visitor id to the screener" do
          get :index
          expect(screener.visitor_id).to eq cookies.encrypted[:visitor_id]
        end
      end
    end
  end

  describe "#visitor_id" do
    before do
      cookies.encrypted[:visitor_id] = "123"
    end

    it "returns the id from the cookies if no current intake" do
      get :index

      expect(subject.visitor_id).to eq "123"
    end

    context "with a current screener that has a visitor id" do
      let(:screener) { create :screener, visitor_id: "456" }

      before do
        allow(subject).to receive(:current_screener).and_return(screener)
      end

      it "gives the screener precedent over the cookies" do
        get :index

        expect(subject.visitor_id).to eq "456"
      end
    end
  end

  describe "#send_mixpanel_event" do
    let(:current_screener) { create :screener }

    before do
      allow(MixpanelService).to receive(:send_event)
      allow(subject).to receive(:visitor_id).and_return "123"
      allow(subject).to receive(:current_screener).and_return current_screener
    end

    it "calls MixpanelService with the current screener and the controller" do
      subject.send_mixpanel_event(event_name: "event")

      expect(MixpanelService).to have_received(:send_event).with(
        {
          distinct_id: "123",
          event_name: "event",
          record: current_screener,
          controller: subject
        }
      )
    end
  end

  describe "#track_page_view" do
    before do
      allow(subject).to receive(:send_mixpanel_event)
    end

    context "request is get" do
      it "sends an event" do
        get :index

        expect(subject).to have_received(:send_mixpanel_event).with({event_name: "page_view"})
      end
    end

    context "request is not get" do
      it "does not send an event" do
        post :create

        expect(subject).not_to have_received(:send_mixpanel_event)
      end
    end
  end
end

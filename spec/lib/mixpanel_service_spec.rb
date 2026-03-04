require "rails_helper"

describe MixpanelService do
  let(:mixpanel_tracker_double) { instance_double(Mixpanel::Tracker) }

  before do
    allow(Rails.env).to receive(:production?).and_return(true)
    allow(Mixpanel::Tracker).to receive(:new).and_return mixpanel_tracker_double
    allow(mixpanel_tracker_double).to receive(:track)
  end

  describe "#send_event" do
    it "calls the tracker with the correct arguments" do
      screener = create(:screener)
      controller_double = instance_double(HomepageController)
      allow(controller_double).to receive(:class).and_return HomepageController
      allow(controller_double).to receive(:action_name).and_return "index"

      MixpanelService.new.send_event(
        distinct_id: "123",
        event_name: "page_view",
        record: screener,
        controller: controller_double
      )
      expect(mixpanel_tracker_double).to have_received(:track).with(
        "123",
        "page_view",
        {
          record_type: "Screener",
          record_id: screener.id,
          controller_action: "HomepageController#index",
          locale: :en
        }
      )
    end
  end
end

# require 'mixpanel-ruby'

class MixpanelService
  def initialize(api_key)
    @tracker = Mixpanel::Tracker.new("YOUR_PROJECT_TOKEN")
  end

  def track(record_id:, event_name:, data: {})
    @tracker.track(record_id, event_name, data)
  rescue StandardError => err
    Rails.logger.error "Error tracking Mixpanel event #{err}"
  end

  def send_event(distinct_id:, event_name:, record:, request:, controller:)
    data = {
    #   controller, record, and request stuff
    }

    track(record_id: distinct_id, event_name: event_name, data: data)
  end
end

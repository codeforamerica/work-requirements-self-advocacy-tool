class MixpanelService
  def initialize(api_key)
    @tracker = Mixpanel::Tracker.new("YOUR_PROJECT_TOKEN")
  end

  def track(record_id:, event_name:, data: {})
    @tracker.track(record_id, event_name, data)
  rescue StandardError => err
    Rails.logger.error "Error tracking Mixpanel event #{err}"
  end

  def send_event(distinct_id:, event_name:, record:, controller:)
    data = {
      record_type: record.class.to_s,
      record_id: record.id,
      controller_action: "#{controller.class.name}##{controller.action_name}",
    }

    track(record_id: distinct_id, event_name: event_name, data: data)
  end
end

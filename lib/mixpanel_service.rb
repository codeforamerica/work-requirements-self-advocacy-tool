class MixpanelService
  def initialize
    @tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
  end

  def send_event(distinct_id:, event_name:, record:, controller:)
    data = {
      record_type: record&.class.to_s,
      record_id: record&.id,
      controller_action: "#{controller.class.name}##{controller.action_name}",
      locale: I18n.locale
    }

    begin
      @tracker.track(distinct_id, event_name, data)
    rescue => err
      Rails.logger.error "Error tracking Mixpanel event #{err}"
    end
  end
end

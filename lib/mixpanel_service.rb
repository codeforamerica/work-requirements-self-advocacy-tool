require "singleton"

class MixpanelService
  MAX_BUFFER_SIZE = 50
  FLUSH_DELAY = 5

  include Singleton

  def initialize
    mixpanel_key = ENV["MIXPANEL_TOKEN"]
    return if mixpanel_key.nil?

    @buffer = []
    @mutex = Mutex.new

    @tracker = Mixpanel::Tracker.new(mixpanel_key) do |type, message|
      buffer_event_for_send(type, message)
    end
  end

  def run(distinct_id:, event_name:, data: {})
    @tracker.track(distinct_id, event_name, data)
  rescue => err
    Rails.logger.error "Error tracking Mixpanel analytics event #{err}"
  end

  private

  def buffer_event_for_send(type, message)
    buffer = nil
    @mutex.synchronize do
      buffer = @buffer
      buffer << [type, message]
      @flusher&.cancel
      if buffer.length < MAX_BUFFER_SIZE
        init_flusher
        return
      else
        @buffer = []
      end
    end
    if buffer.length >= MAX_BUFFER_SIZE
      send_buffered_events_to_mixpanel(buffer)
    end
  end

  def init_flusher
    @flusher = Concurrent::ScheduledTask.new(FLUSH_DELAY) do
      buffer = nil
      @mutex.synchronize do
        buffer = @buffer
        @buffer = []
      end
      send_buffered_events_to_mixpanel(buffer)
    end
    @flusher.execute
  end

  def send_buffered_events_to_mixpanel(buffer)
    consumer = Mixpanel::BufferedConsumer.new(nil, nil, nil, MAX_BUFFER_SIZE + 1)
    buffer.each do |type, message|
      consumer.send!(type, message)
    end
    consumer.flush
  end

  class << self
    def send_event(distinct_id:, event_name:, record: nil, controller: nil)
      data = {
        locale: I18n.locale
      }

      if record
        record_data = {
          record_type: record&.class.to_s,
          record_id: record&.id
        }
        data.merge!(record_data)
      end

      if controller
        controller_data = {
          controller_name: controller&.class&.name&.sub("Controller", ""),
          controller_action: "#{controller&.class&.name}##{controller&.action_name}",
          **controller.utms_and_referrer.compact
        }
        data.merge!(controller_data)
      end

      MixpanelService.instance.run(
        distinct_id: distinct_id,
        event_name: event_name,
        data: data
      )
    end
  end
end

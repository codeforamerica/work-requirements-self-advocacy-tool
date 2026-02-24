Rails.application.configure do
  config.lograge.enabled = true
  config.colorize_logging = false

  # Use Raw so it passes a Hash to the logger
  config.lograge.formatter = Lograge::Formatters::Raw.new

  # Prevent Rails default request logging
  config.lograge.keep_original_rails_log = false

  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params]&.except("controller", "action"),
      request_id: event.payload[:request_id],
      session_id: RequestStore.store[:session_id],
      screener_id: RequestStore.store[:screener_id]
    }.compact
  end
end

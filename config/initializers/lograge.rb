Rails.application.configure do
  # Lograge config
  config.lograge.enabled = true

  # This specifies to log in JSON format
  config.lograge.formatter = Lograge::Formatters::Raw.new

  ## Disables log coloration
  config.colorize_logging = false

  # Log to the same place as Rails logs
  config.lograge.logger = Rails.logger

  # This is useful if you want to log query parameters
  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params]&.reject { |k| %w(controller action).include? k },
      request_details: event.payload[:request_details],
      level: event.payload[:level],
      request_id: event.payload[:request_id] || event.payload[:headers]["action_dispatch.request_id"],
      session_id: RequestStore.store[:session_id],
      screener_id: RequestStore.store[:screener_id]
    }
  end
end

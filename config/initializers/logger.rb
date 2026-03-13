# frozen_string_literal: true

require Rails.root.join("lib", "log_formatter")

Rails.application.configure do
  # Setup structured logging
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.semantic_logger.application = "getbenefitshelp"
  config.semantic_logger.environment = Rails.env

  config.rails_semantic_logger.add_file_appender = false
  config.semantic_logger.add_appender(io: $stdout, formatter: LogFormatter.new)
end

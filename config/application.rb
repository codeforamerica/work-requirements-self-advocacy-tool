require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WorkRequirementsSelfAdvocacyTool
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    I18n.load_path += Dir[Rails.root.join("config", "locales", "*.yml")]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.available_locales = [:en, :es]

    config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
    # Change to "debug" to log everything (including potentially personally-identifiable information!)
    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
    config.log_tags = []

    # If gem "image_processing", "~> 1.2" is added/uncommented out in Gemfile, this should be removed
    # Otherwise, this prevents the application from unnecessarily logging:
    # Generating image variants require the image_processing gem. Please add `gem "image_processing", "~> 1.2"`
    # to your Gemfile or set `config.active_storage.variant_processor = :disabled`.
    config.active_storage.variant_processor = :disabled

    # Silence the queue polling logs by default, since they're very noisy.
    config.solid_queue.silence_polling = ENV.fetch("SOLID_QUEUE_SILENCE_POLLING", "true") == "true"
  end
end

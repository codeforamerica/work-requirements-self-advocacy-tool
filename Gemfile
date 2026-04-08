source "https://rubygems.org"

ruby_version = File.read(File.join(File.dirname(__FILE__), ".ruby-version")).strip
ruby ruby_version

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
gem "aws-sdk-rails", "~> 5"
gem "aws-actionmailer-ses", "~> 1"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem "cfa-styleguide", "0.18.0", git: "https://github.com/codeforamerica/honeycrisp-gem"
gem "csv"
gem "dartsass-rails", "~> 0.5.1"
gem "devise", "~> 5.0"
gem "grover"
gem "hexapdf", "~> 1.6"
gem "mixpanel-ruby"
gem "opentelemetry-exporter-otlp", "~> 0.32"
gem "opentelemetry-instrumentation-all", "~> 0.91"
gem "opentelemetry-resource-detector-aws", "~> 0.5"
gem "opentelemetry-sdk", "~> 1.11"
gem "ostruct"
gem "pg-aws_rds_iam", "~> 0.8"
gem "phonelib"
gem "rails_semantic_logger", "~> 4.19"
gem "request_store", "~> 1.7"
gem "valid_email2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "dotenv"
  gem "i18n-tasks", "~> 1.1.2"

  gem "factory_bot_rails"
  gem "rails-controller-testing"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "standard", ">= 1.35.1"
  gem "pry", "~> 0.16.0"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails"
end

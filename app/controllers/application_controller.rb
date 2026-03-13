class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action do
    RequestStore.store[:session_id] = session.id
    RequestStore.store[:screener_id] = current_screener&.id
    capture_trace_context
  end
  before_action :set_visitor_id
  after_action :track_page_view

  def navigation_class
    Navigation::ScreenerNavigation
  end
  helper_method :navigation_class

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
  around_action :switch_locale

  def self.default_url_options
    {locale: I18n.locale}
  end

  def clear_flashes
    flash.clear
    redirect_back(fallback_location: root_path)
  end

  def set_visitor_id
    visitor_id =
      if current_screener&.visitor_id.present?
        current_screener.visitor_id
      elsif cookies.encrypted[:visitor_id].present?
        cookies.encrypted[:visitor_id]
      else
        SecureRandom.uuid
      end
    cookies.encrypted.permanent[:visitor_id] = {value: visitor_id, httponly: true}

    # if current_screener is present but for some reason lacking a visitor_id, let's update it
    if current_screener.present? && current_screener.persisted? && current_screener.visitor_id.blank?
      current_screener.update(visitor_id: visitor_id)
    end
  end

  def visitor_id
    current_screener&.visitor_id || cookies.encrypted[:visitor_id]
  end

  def send_mixpanel_event(event_name:)
    MixpanelService.send_event(
      distinct_id: visitor_id,
      event_name: event_name,
      record: current_screener,
      controller: self
    )
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.method == "GET"
  end

  # Store trace/span IDs in RequestStore so the log formatter can attach them even
  # when it runs in a different fiber (OpenTelemetry context is fiber-local).
  def capture_trace_context
    span = OpenTelemetry::Trace.current_span
    return unless span.recording?

    RequestStore.store[:trace_id] = span.context.hex_trace_id if span.context.trace_id != 0
    RequestStore.store[:span_id] = span.context.hex_span_id if span.context.span_id != 0
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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

  def visitor_id
  #   ???
  end

  def send_mixpanel_event(event_name:)
    MixpanelService.send_event(
      distinct_id: visitor_id,
      event_name: event_name,
      record: current_screener,
      request: request,
      controller: self
    )
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.get?
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action do
    RequestStore.store[:session_id] = session.id
    RequestStore.store[:screener_id] = session[:screener_id]
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

  def current_screener
  end

  def set_visitor_id
    visitor_id =
      if current_screener&.visitor_id.present?
        current_screener.visitor_id
      elsif cookies.encrypted[:visitor_id].present?
        cookies.encrypted[:visitor_id]
      else
        SecureRandom.hex(26)
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
    MixpanelService.new.send_event(
      distinct_id: visitor_id,
      event_name: event_name,
      record: current_screener,
      controller: self
    )
  end

  def track_page_view
    if request.get?
      send_mixpanel_event(event_name: "page_view")
    elsif request.post?
    #   will this make brakeman happy?
    end
  end
end

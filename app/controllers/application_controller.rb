class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action do
    RequestStore.store[:session_id] = session.id
    RequestStore.store[:screener_id] = session[:screener_id]
  end

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
end

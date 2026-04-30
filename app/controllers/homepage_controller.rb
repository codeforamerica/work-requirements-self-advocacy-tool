class HomepageController < ApplicationController
  layout "application"

  def index
  end

  def create_screener
    screener = Screener.create(visitor_id: cookies.encrypted[:visitor_id], source: session[:source])
    sign_in screener
    redirect_to navigation_class.first.to_path_helper
  end

  def redirect_without_source
    needed_locale = (locale == I18n.default_locale) ? nil : locale

    path_part = [needed_locale, params[:base_path].presence].compact.join("/")
    redirect_to "/#{path_part}?source=#{params[:intended_source]}"
  end
end

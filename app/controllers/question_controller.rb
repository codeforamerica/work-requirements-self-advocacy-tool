class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController

  around_action :switch_locale

  def current_screener
    Screener.last
  end

  def switch_locale(&action)
    I18n.with_locale(locale, &action)
  end

  def locale
    current_screener.locale || params[:locale] || I18n.default_locale
  end

  def self.default_url_options
    {locale: I18n.locale}
  end
end

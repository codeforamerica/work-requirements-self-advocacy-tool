class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  helper_method :show_progress_bar

  around_action :switch_locale

  def current_screener
    Screener.last
  end

  def show_progress_bar
    true
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

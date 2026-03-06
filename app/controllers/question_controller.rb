class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  attr_accessor :current_screener

  helper_method :show_progress_bar

  def current_screener
    @current_screener = Screener.last
  end

  def show_progress_bar
    true
  end
end

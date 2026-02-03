class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController

  helper_method :show_progress_bar

  def current_screener
    Screener.last
  end

  def show_progress_bar
    true
  end
end

class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController

  def current_screener
    Screener.last
  end
end

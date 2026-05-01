class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  include AuthenticatedConcern

  helper_method :show_progress_bar

  def show_progress_bar
    true
  end
end

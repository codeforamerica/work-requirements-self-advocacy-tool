class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  include AuthenticatedConcern

  helper_method :show_progress_bar

  def show_progress_bar
    true
  end

  def self.show?(screener)
    return false unless screener.age
    screener.age.to_i < 65 && screener.age.to_i >= 18
  end
end

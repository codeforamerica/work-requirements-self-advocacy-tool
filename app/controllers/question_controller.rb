class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  include AuthenticatedConcern

  helper_method :show_progress_bar, :show_progress_percentage, :percent_complete

  def show_progress_bar
    true
  end

  def show_progress_percentage
    true
  end

  def percent_complete
    navigation_class.get_progress_percentage(self.class)
  end

  def self.show?(screener)
    return false unless screener.age
    screener.age < 65 && screener.age >= 18
  end
end

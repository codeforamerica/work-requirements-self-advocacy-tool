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
    screener.age < 65 && screener.age >= 18
  end

  private

  def save_outcome
    return if current_screener.outcome_arrived_at.present? && current_screener.outcome == outcome_value
    current_screener.update!(outcome: outcome_value, outcome_arrived_at: Time.current)
  end
end

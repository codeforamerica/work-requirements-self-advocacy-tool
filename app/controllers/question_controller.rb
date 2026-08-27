class QuestionController < ApplicationController
  include ControllerNavigation::NavigableController
  include Forms::FormController
  include AuthenticatedConcern

  # show? determines which page comes next during navigation, but on its own it
  # doesn't stop a direct visit to a page the screener isn't eligible for.
  # Registering this gate here (in the superclass) guarantees it runs before
  # subclass before_actions with side effects, like save_outcome and email_pdf.
  before_action :ensure_page_navigable

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
    # Screeners routed to the out-of-state page (state not listed or county not
    # supported) are done with the flow and can't see any other question page.
    return false if OutOfStateController.show?(screener)
    return false unless screener.age
    !screener.age_exempt?
  end

  private

  def ensure_page_navigable
    redirect_to root_path unless self.class.show?(current_screener)
  end

  def save_outcome
    return if current_screener.outcome_arrived_at.present? && current_screener.outcome == outcome_value
    current_screener.update!(outcome: outcome_value, outcome_arrived_at: Time.current)
  end
end

class AgeExemptionController < QuestionController
  before_action :save_outcome, only: :display

  def show_progress_bar
    false
  end

  def show_progress_percentage
    false
  end

  def self.show?(screener)
    # Not simply !super: this page is only for screeners whose age is known and
    # age-exempt, never for those missing a birth date or routed out-of-state.
    !OutOfStateController.show?(screener) && screener.age_qualified?
  end

  private

  def outcome_value
    Screener::AGE_EXEMPT
  end
end

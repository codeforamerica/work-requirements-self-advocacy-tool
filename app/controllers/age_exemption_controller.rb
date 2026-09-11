class AgeExemptionController < QuestionController
  before_action :save_outcome, only: :display

  def show_progress_bar
    false
  end

  def show_progress_percentage
    false
  end

  def self.show?(screener)
    !screener.unsupported_location? && screener.age_qualified?
  end

  private

  def outcome_value
    Screener::AGE_EXEMPT
  end
end

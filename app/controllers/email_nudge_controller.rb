class EmailNudgeController < QuestionController
  include BasicInfoConcern
  def show?(screener, item_index: nil)
    # screener.reload
    # !screener.email.present?
    false
  end
end

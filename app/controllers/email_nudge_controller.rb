class EmailNudgeController < QuestionController
  include BasicInfoConcern

  def self.show?(screener, item_index: nil)
    !screener.email.present?
  end
end

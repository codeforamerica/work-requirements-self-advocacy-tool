class BasicInfoEmailNudgeController < QuestionController
  include BasicInfoConcern

  def self.show?(screener)
    screener.email.blank?
  end
end

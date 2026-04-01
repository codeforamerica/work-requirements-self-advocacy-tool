class ExemptionAwareQuestionController < QuestionController
  def self.show?(screener)
    screener&.exempt_from_work_rules? && super
  end
end

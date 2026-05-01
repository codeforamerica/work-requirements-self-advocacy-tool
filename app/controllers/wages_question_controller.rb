class WagesQuestionController < QuestionController
  def self.show?(screener)
    !screener.has_exemption?
  end
end

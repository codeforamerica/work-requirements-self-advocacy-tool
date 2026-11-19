class StudentQuestionController < QuestionController
  def self.show?(screener)
    return false if Rails.env.production?

    # TODO(WRSAT-817): when is_student is removed from OTHER_EXEMPTION_ATTRIBUTES, replace with
    # `!screener.has_exemption? && !screener.has_earnings_exemption? && screener.is_student_yes?`
    screener.exemption_reasons == ["is_student"] &&
      screener.age_range_18_to_49? &&
      super
  end
end

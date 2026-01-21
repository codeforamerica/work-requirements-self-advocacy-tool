class IsStudentController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_student]
  end
end

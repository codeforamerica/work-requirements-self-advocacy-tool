class SchoolEnrollmentController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_student, :school_type]
  end
end

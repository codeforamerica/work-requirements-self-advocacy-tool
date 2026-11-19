class SchoolTypeController < StudentQuestionController
  include PersonalSituationsConcern

  def self.attributes_edited
    [:student_school_type]
  end
end

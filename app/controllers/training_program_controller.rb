class TrainingProgramController < QuestionController
  include WrExemptionsConcern

  def self.show?(screener)
    false
  end

  def self.attributes_edited
    [
      :is_in_work_training,
      :work_training_hours,
      :work_training_name
    ]
  end
end

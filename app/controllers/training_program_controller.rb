class TrainingProgramController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [
      :is_in_work_training,
      :work_training_hours,
      :work_training_name
    ]
  end
end

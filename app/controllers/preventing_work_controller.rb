class PreventingWorkController < QuestionController
  include PersonalSituationsConcern

  def self.attributes_edited
    [
      :preventing_work_place_to_sleep,
      :preventing_work_drugs_alcohol,
      :preventing_work_domestic_violence,
      :preventing_work_medical_condition,
      :preventing_work_other,
      :preventing_work_none,
      :preventing_work_write_in
    ]
  end
end

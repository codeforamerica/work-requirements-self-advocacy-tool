class PreventingWorkReasonController < QuestionController
  include PersonalSituationsConcern

  PREVENTING_WORK_FIELDS = %i[
    preventing_work_place_to_sleep
    preventing_work_drugs_alcohol
    preventing_work_domestic_violence
    preventing_work_medical_condition
    preventing_work_other
  ].freeze

  def edit
    super

    @conditions_count = preventing_work_conditions_count

    redirect_to(next_path) if @conditions_count.zero?
  end

  def preventing_work_conditions_count
    PREVENTING_WORK_FIELDS.count do |field|
      value = @model.public_send(field)
      value == "yes"
    end
  end

  def self.attributes_edited
    [
      :preventing_work_additional_info
    ]
  end

end

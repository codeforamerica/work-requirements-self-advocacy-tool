class PreventingWorkReasonController < QuestionController
  include PersonalSituationsConcern

  CHARACTER_LIMIT = 1000

  PREVENTING_WORK_FIELDS = %i[
    preventing_work_place_to_sleep
    preventing_work_drugs_alcohol
    preventing_work_domestic_violence
    preventing_work_medical_condition
    preventing_work_other
  ].freeze

  def edit
    super
    @conditions_count = self.class.conditions_count(@model)
  end

  def self.attributes_edited
    [
      :preventing_work_additional_info
    ]
  end

  def self.show?(screener, item_index: nil)
    !conditions_count(screener).zero?
  end

  def self.conditions_count(screener)
    return 0 unless screener

    PREVENTING_WORK_FIELDS.count do |field|
      screener.public_send(field) == "yes"
    end
  end
end

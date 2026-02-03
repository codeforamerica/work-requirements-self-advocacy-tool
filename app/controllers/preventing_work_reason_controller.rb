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

  helper_method :conditions_count

  def edit
    super
    setup_edit
  end

  def self.attributes_edited
    [
      :preventing_work_additional_info
    ]
  end

  def setup_edit
    if conditions_count.zero?
      clear_preventing_work_additional_info
      redirect_to(next_path)
    end
  end

  def clear_preventing_work_additional_info
    screener = current_screener
    return unless screener

    # Only save if there’s a value to clear
    if screener.preventing_work_additional_info.present?
      screener.update!(preventing_work_additional_info: nil)
    end
  end

  def conditions_count
    return @conditions_count if defined?(@conditions_count)

    screener = current_screener
    return @conditions_count = 0 unless screener

    @conditions_count = PREVENTING_WORK_FIELDS.count do |field|
      screener.public_send(field) == "yes"
    end
  end
end

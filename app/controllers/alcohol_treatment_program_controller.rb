class AlcoholTreatmentProgramController < QuestionController
  include WrExemptionsConcern

  CHARACTER_LIMIT = 50

  def self.attributes_edited
    [:is_in_alcohol_treatment_program, :alcohol_treatment_program_name]
  end
end

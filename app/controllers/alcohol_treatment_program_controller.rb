class AlcoholTreatmentProgramController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_in_alcohol_treatment_program, :alcohol_treatment_program_name]
  end
end

module ProofGuidanceHelper
  def proof_of_condition_title_and_type(screener)
    has_substance_use_condition = screener.preventing_work_drugs_alcohol_yes?
    has_medical_condition = screener.preventing_work_medical_condition_yes?

    if has_medical_condition && has_substance_use_condition
      [
        t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title"),
        t("views.proof_guidance.edit.condition_medical_health")
      ]
    elsif has_medical_condition
      [
        t("views.proof_guidance.edit.proof_of_health_condition_only_title"),
        t("views.proof_guidance.edit.condition_medical_health")
      ]
    elsif has_substance_use_condition
      [
        t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title"),
        t("views.proof_guidance.edit.condition_substance_use")
      ]
    end
  end
end

class DisabilityBenefitsController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [
      :receiving_benefits_ssdi,
      :receiving_benefits_ssi,
      :receiving_benefits_veterans_disability,
      :receiving_benefits_disability_pension,
      :receiving_benefits_workers_compensation,
      :receiving_benefits_insurance_payments,
      :receiving_benefits_other,
      :receiving_benefits_none,
      :receiving_benefits_write_in
    ]
  end
end

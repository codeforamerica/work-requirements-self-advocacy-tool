class HasUnemploymentBenefitsController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:has_unemployment_benefits]
  end
end

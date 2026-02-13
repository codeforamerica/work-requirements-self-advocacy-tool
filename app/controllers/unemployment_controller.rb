class UnemploymentController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:has_unemployment_benefits]
  end
end

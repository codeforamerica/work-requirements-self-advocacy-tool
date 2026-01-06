class HasChildController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:has_child]
  end
end

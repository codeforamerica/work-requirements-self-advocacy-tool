class TribeOrNationController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_american_indian]
  end
end

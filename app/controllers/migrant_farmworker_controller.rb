class MigrantFarmworkerController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_migrant_farmworker]
  end
end

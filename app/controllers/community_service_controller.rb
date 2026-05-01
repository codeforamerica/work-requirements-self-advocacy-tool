class CommunityServiceController < QuestionController
  include WrExemptionsConcern

  def self.show?(screener)
    false
  end

  def self.attributes_edited
    [:is_volunteer, :volunteering_hours, :volunteering_org_name]
  end
end

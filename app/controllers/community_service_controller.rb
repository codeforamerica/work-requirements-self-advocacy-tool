class CommunityServiceController < WagesQuestionController
  include PersonalSituationsConcern

  def self.attributes_edited
    [:is_volunteer, :volunteering_hours, :volunteering_org_name]
  end
end

class WagesHoursMilestoneController < WagesQuestionController
  include PersonalSituationsConcern

  def self.navigation_actions
    [:display]
  end
end

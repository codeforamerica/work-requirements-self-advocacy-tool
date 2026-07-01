class PreventingWorkMilestoneController < QuestionController
  include PersonalSituationsConcern

  def self.navigation_actions
    [:display]
  end
end

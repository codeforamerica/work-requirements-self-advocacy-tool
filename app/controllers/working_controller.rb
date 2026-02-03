class WorkingController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:is_working, :working_hours, :working_weekly_earnings]
  end
end

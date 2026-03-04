class LocationController < QuestionController

  def show_progress_bar
    false
  end

  def edit
    @model ||= current_screener
    @states = LocationData::States::OPTIONS
    @all_counties = LocationData::Counties::ALL_COUNTIES
    super
  end

  def self.attributes_edited
    [:state, :county]
  end
end

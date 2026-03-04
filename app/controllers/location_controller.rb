class LocationController < QuestionController

  def show_progress_bar
    false
  end

  def edit
    @model ||= current_screener
    @states = LocationData::States::OPTIONS

    # Prepopulate counties for the current state
    @counties = LocationData::Counties.options_for(@model.state)

    super
  end

  def self.attributes_edited
    [:state, :county]
  end
end

class LocationController < QuestionController
  include DateHelper

  def show_progress_bar
    false
  end

  def edit
    @states = LocationData::States::OPTIONS

    # Only prepopulate counties if state is North Carolina
    @counties = if current_screener.state == LocationData::States::NORTH_CAROLINA
                  LocationData::Counties::NORTH_CAROLINA
                else
                  {}
                end

    super
  end

  def self.attributes_edited
    [:state, :county]
  end
end

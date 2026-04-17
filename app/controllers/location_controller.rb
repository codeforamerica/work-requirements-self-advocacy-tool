class LocationController < QuestionController
  def show_progress_bar
    false
  end

  def edit
    @all_counties = LocationData::Counties::ALL_COUNTIES
    super
  end

  def self.attributes_edited
    [:state, :county]
  end

  private

  def after_update_success
    if current_screener.state == LocationData::States::NORTH_CAROLINA && current_screener.nc_screener.nil?
      current_screener.create_nc_screener
    end
    send_mixpanel_event(
      event_name: "page_submit",
      data: {state: current_screener.state, county: current_screener.county}
    )
  end
end

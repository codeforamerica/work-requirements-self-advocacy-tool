class OutOfStateController < QuestionController
  def show_progress_bar
    false
  end

  helper_method :not_listed?, :county_not_supported?, :county

  def not_listed?
    self.class.not_listed?(@current_screener)
  end

  def county
    LocationData::Counties.get(@current_screener.state, @current_screener.county)
  end

  def self.not_listed?(screener)
    screener.state == LocationData::States::NOT_LISTED
  end

  def self.county_not_supported?(screener)
    county = LocationData::Counties.get(screener.state, screener.county)
    county.present? && !county[:is_supported]
  end

  def self.show?(screener, item_index: nil)
    not_listed?(screener) || county_not_supported?(screener)
  end
end

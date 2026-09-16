class OutOfStateController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    screener.unsupported_location?
  end

  helper_method :not_listed?, :county, :redirect_delay_seconds

  def self.county(screener)
    LocationData::Counties.get(screener.state, screener.county)
  end
  delegate :county, to: :class

  def self.not_listed?(screener)
    screener.state == LocationData::States::NOT_LISTED
  end
  delegate :not_listed?, to: :class

  def redirect_delay_seconds
    10
  end
end

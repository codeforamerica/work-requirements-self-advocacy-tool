class OutOfStateController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    not_listed?(screener) || county_not_supported?(screener)
  end

  helper_method :not_listed?, :county, :redirect_delay_seconds

  def self.county(screener)
    LocationData::Counties.get(screener.state, screener.county)
  end
  delegate :county, to: :class

  def self.county_not_supported?(screener)
    office_by = LocationData::States::STATES_INFO.dig(screener.state, :office_by)
    unless office_by
      Rails.logger.warn("county_not_supported? called with unrecognized state | screener_id=#{screener.id} | state=#{screener.state.inspect}")
    end
    return false unless office_by == :county

    county = county(screener)
    county.present? && !county[:is_supported]
  end

  def self.not_listed?(screener)
    screener.state == LocationData::States::NOT_LISTED
  end
  delegate :not_listed?, to: :class

  def redirect_delay_seconds
    10
  end
end

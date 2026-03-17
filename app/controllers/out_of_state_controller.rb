class OutOfStateController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener, item_index: nil)
    screener.state == LocationData::States::NOT_LISTED || (!!screener.county && !LocationData::Counties.get(screener.state, screener.county)[:is_supported])
  end
end

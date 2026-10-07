class AgeRangeController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    !screener.unsupported_location?
  end

  def self.attributes_edited
    [:age_range]
  end
end

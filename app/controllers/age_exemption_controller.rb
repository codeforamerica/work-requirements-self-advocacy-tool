class AgeExemptionController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    !super
  end

  def show_progress_percentage
    false
  end
end

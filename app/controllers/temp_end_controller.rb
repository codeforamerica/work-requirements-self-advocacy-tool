class TempEndController < QuestionController
  def current_screener
    Screener.last
  end
end

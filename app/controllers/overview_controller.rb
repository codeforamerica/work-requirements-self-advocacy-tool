class OverviewController < QuestionController
  def prev_path
    root_path
  end

  def show_progress_bar
    false
  end
end

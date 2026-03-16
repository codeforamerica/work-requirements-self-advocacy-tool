class OutOfStateController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener, item_index: nil)
    true
  end

  def sign_out_and_redirect
    sign_out current_screener
    redirect_path = params[:redirect_path] || root_path
    redirect_to redirect_path
  end
end

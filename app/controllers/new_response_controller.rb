class NewResponseController < QuestionController
  def sign_out_and_redirect
    sign_out current_screener
    redirect_path = params[:redirect_path] || root_path
    redirect_to redirect_path
  end

  def show_progress_bar
    false
  end
end

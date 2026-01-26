class BirthDateController < QuestionController
  include DateHelper

  def show_progress_bar
    false
  end

  private

  def form_params(model)
    model_from_params = params["screener"]
    birth_date = parse_date_params(model_from_params[:birth_date_year].to_i, model_from_params[:birth_date_month].to_i, model_from_params[:birth_date_day].to_i)
    {birth_date: birth_date}
  end
end

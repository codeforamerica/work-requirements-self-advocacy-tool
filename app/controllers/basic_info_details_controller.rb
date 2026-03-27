class BasicInfoDetailsController < QuestionController
  include BasicInfoConcern
  include DateHelper

  def self.attributes_edited
    [:first_name, :middle_name, :last_name, :phone_number, :consented_to_texts, :birth_date]
  end

  private

  def form_params(model)
    model_from_params = params["screener"]

    birth_date = parse_date_params(
      model_from_params[:birth_date_year],
      model_from_params[:birth_date_month],
      model_from_params[:birth_date_day]
    )

    super.merge(birth_date: birth_date)
  end
end

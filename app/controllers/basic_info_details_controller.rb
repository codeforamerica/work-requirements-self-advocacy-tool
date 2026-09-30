class BasicInfoDetailsController < ExemptionAwareQuestionController
  include BasicInfoConcern
  include DateHelper

  def self.attributes_edited
    [:first_name, :middle_name, :last_name, :phone_number, :consented_to_texts, :birth_date]
  end

  private

  def form_params(model)
    model_from_params = params["screener"] || {}
    year, month, day = model_from_params.values_at(:birth_date_year, :birth_date_month, :birth_date_day)

    # Set the raw entries directly on the model so an invalid date (e.g. Feb 30) is
    # redisplayed instead of cleared. Leave them of the returned hash so they don't get sent to Mixpanel.
    model.birth_date_year = year
    model.birth_date_month = month
    model.birth_date_day = day

    birth_date = parse_date_params(year, month, day)

    super.merge(birth_date: birth_date)
  end
end

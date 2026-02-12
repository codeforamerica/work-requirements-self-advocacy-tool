class PregnancyController < QuestionController
  include WrExemptionsConcern
  include DateHelper

  def self.attributes_edited
    [:is_pregnant, :pregnancy_due_date]
  end

  private

  def form_params(model)
    model_from_params = params[model.class.params_key]
    date_params = [model_from_params[:pregnancy_due_date_year], model_from_params[:pregnancy_due_date_month], model_from_params[:pregnancy_due_date_day]]
    if date_params.all?(&:present?)
      pregnancy_due_date = parse_date_params(*date_params)
    end
    params.expect(model.class.params_key => self.class.attributes_edited).merge({pregnancy_due_date: pregnancy_due_date})
  end
end

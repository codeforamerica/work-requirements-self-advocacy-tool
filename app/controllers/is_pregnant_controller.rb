class IsPregnantController < QuestionController
  include WrExemptionsConcern
  include DateHelper

  def self.attributes_edited
    [:is_pregnant, :pregnancy_due_date]
  end

  private

  def form_params(model)
    model_from_params = params[model.class.params_key]
    pregnancy_due_date = parse_date_params(model_from_params[:pregnancy_due_date_year].to_i, model_from_params[:pregnancy_due_date_month].to_i, model_from_params[:pregnancy_due_date_day].to_i)
    params.expect(model.class.params_key => self.class.attributes_edited).merge({pregnancy_due_date: pregnancy_due_date})
  end
end

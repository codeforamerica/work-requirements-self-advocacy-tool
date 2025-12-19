class PersonalInformationController < QuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:first_name, :middle_name, :last_name, :birth_date]
  end

  private

  def form_params(model)
    model_from_params = params[model.class.params_key]
    birth_date = Date.new(model_from_params[:birth_date_year].to_i, model_from_params[:birth_date_month].to_i, model_from_params[:birth_date_day].to_i)
    params.expect(model.class.params_key => self.class.attributes_edited).merge({ birth_date: birth_date })
  end
end
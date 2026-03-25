class BasicInfoEmailController < QuestionController
  include BasicInfoConcern

  before_action :set_from_download_form

  def self.attributes_edited
    [:email, :email_confirmation, :from_download_form]
  end

  # allow the hidden field to come through
  def form_params(model)
    permitted = params.require(model.class.params_key)
      .permit(*self.class.attributes_edited)

    # convert string -> boolean
    model.from_download_form = ActiveModel::Type::Boolean.new.cast(permitted[:from_download_form])
    permitted.except(:from_download_form)
  end

  def set_from_download_form
    current_screener.from_download_form ||= params[:source] == "download-form"
  end
end

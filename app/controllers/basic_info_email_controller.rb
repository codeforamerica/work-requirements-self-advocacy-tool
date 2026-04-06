class BasicInfoEmailController < ExemptionAwareQuestionController
  include BasicInfoConcern

  before_action :set_from_download_form

  def self.attributes_edited
    [:email, :email_confirmation, :from_download_form, :return_to_review]
  end

  def set_from_download_form
    current_screener.from_download_form ||= params[:from_download_form] == "true"
  end

  def review_controller
    DownloadFormController
  end

  private

  def after_update_success
    @model.update(confirmation_code: SecureRandom.alphanumeric(6).upcase) unless @model.confirmation_code?
  end
end

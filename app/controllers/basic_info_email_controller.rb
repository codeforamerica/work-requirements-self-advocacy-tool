class BasicInfoEmailController < QuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:email, :email_confirmation]
  end

  private

  def after_update_success
    @model.update(confirmation_code: SecureRandom.alphanumeric(6).upcase) unless @model.confirmation_code?
  end
end

class SignatureController < ExemptionAwareQuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:signature, :signed_at]
  end

  private

  def after_update_success
    current_screener.update(signed_at: Time.now)
  end
end

class EmailController < QuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:email, :email_confirmation]
  end
end

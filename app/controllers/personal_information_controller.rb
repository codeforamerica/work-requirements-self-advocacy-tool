class PersonalInformationController < QuestionController
  include BasicInfoConcern

  def self.attributes_edited
    [:first_name, :middle_name, :last_name, :phone_number, :consented_to_texts]
  end
end

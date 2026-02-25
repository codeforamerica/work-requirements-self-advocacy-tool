class CaringForSomeoneController < QuestionController
  include WrExemptionsConcern

  CHARACTER_LIMIT = 250

  def self.attributes_edited
    [:caring_for_child_under_6, :caring_for_disabled_or_ill_person, :caring_for_no_one, :additional_care_info]
  end
end

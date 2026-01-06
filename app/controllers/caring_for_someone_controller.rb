class CaringForSomeoneController < QuestionController
  include WrExemptionsConcern

  def self.attributes_edited
    [:caring_for_child_under_6, :caring_for_disabled_or_ill_person, :caring_for_no_one]
  end

  def form_params(model)
    params["screener"][:caring_for_no_one] = params["screener"].delete(:none).to_i
    super
  end
end

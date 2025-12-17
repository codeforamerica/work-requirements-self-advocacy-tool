class ReceivingBenefitsController < QuestionController

  def self.attributes_edited
    [:is_receiving_snap_benefits]
  end
end

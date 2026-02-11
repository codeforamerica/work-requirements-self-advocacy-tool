class AddReceivingBenefitsDisabilityMedicaidToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :receiving_benefits_disability_medicaid, :integer, null: false, default: 0
  end
end

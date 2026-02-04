class RemoveIsReceivingSnapBenefitsFromScreeners < ActiveRecord::Migration[8.1]
  def change
    remove_column :screeners, :is_receiving_snap_benefits
  end
end

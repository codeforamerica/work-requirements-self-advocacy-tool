class AddIsReceivingBenefisToScreener < ActiveRecord::Migration[8.0]
  def change
    add_column :screeners, :is_receiving_snap_benefits, :boolean
  end
end

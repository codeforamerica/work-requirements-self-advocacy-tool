class AddPreventingWorkColumnsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :preventing_work_place_to_sleep, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_drugs_alcohol, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_domestic_violence, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_medical_condition, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_other, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_none, :integer, null: false, default: 0
    add_column :screeners, :preventing_work_write_in, :string
  end
end

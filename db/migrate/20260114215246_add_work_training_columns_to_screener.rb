class AddWorkTrainingColumnsToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_in_work_training, :integer, null: false, default: 0
    add_column :screeners, :work_training_hours, :string
    add_column :screeners, :work_training_name, :string
  end
end

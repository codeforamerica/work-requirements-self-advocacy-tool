class AddIsPregnantToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_pregnant, :integer, null: false, default: 0
    add_column :screeners, :pregnancy_due_date, :date
  end
end

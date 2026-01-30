class AddWorkingColumnsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_working, :integer, null: false, default: 0
    add_column :screeners, :working_hours, :integer
    add_column :screeners, :working_weekly_earnings, :decimal
  end
end

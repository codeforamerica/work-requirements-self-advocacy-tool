class AddFieldsToNcScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :nc_screeners, :earned_more_than_threshold, :integer, null: false, default: 0
    add_column :nc_screeners, :health_conditions_preventing_work, :integer, null: false, default: 0
  end
end

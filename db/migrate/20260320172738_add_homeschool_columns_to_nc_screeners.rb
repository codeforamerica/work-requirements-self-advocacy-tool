class AddHomeschoolColumnsToNcScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :nc_screeners, :teaches_homeschool, :integer, null: false, default: 0
    add_column :nc_screeners, :homeschool_name, :string
    add_column :nc_screeners, :homeschool_hours, :integer
  end
end

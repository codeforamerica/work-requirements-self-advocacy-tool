class AddStateAndCountyToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :state, :string
    add_column :screeners, :county, :string
  end
end

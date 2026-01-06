class AddIsAmericanIndianToScreeners < ActiveRecord::Migration[8.0]
  def change
    add_column :screeners, :is_american_indian, :integer, null: false, default: 0
  end
end

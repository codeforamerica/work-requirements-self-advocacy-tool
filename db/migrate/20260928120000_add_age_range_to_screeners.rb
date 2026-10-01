class AddAgeRangeToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :age_range, :integer, null: false, default: 0
  end
end

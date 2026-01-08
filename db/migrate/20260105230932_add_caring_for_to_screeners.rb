class AddCaringForToScreeners < ActiveRecord::Migration[8.0]
  def change
    add_column :screeners, :caring_for_child_under_6, :integer, null: false, default: 0
    add_column :screeners, :caring_for_disabled_or_ill_person, :integer, null: false, default: 0
    add_column :screeners, :caring_for_no_one, :integer, null: false, default: 0
  end
end

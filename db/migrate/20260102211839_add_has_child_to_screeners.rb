class AddHasChildToScreeners < ActiveRecord::Migration[8.0]
  def change
    add_column :screeners, :has_child, :integer, null: false, default: 0
  end
end

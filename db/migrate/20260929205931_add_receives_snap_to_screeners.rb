class AddReceivesSnapToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :receives_snap, :integer, null: false, default: 0
  end
end

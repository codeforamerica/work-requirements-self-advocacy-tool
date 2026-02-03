class AddIsMigrantFarmworkerToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_migrant_farmworker, :integer, null: false, default: 0
  end
end

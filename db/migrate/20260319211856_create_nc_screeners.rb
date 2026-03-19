class CreateNcScreeners < ActiveRecord::Migration[8.1]
  def change
    create_table :nc_screeners do |t|
      t.references :screener, null: false, foreign_key: true
      t.integer :has_hs_diploma, null: false, default: 0
      t.integer :worked_last_five_years, null: false, default: 0
      t.timestamps
    end
  end
end

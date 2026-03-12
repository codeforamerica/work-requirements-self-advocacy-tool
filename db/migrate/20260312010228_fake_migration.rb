class FakeMigration < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :boop, :string
  end
end

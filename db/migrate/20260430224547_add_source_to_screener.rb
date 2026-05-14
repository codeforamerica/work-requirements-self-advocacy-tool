class AddSourceToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :source, :string
  end
end

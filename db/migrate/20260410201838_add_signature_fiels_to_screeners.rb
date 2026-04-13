class AddSignatureFielsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :signature, :string
    add_column :screeners, :signed_at, :datetime
  end
end

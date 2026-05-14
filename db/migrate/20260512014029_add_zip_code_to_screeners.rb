class AddZipCodeToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :zip_code, :string
  end
end

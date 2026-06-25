class AddLocaleToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :locale, :string
  end
end

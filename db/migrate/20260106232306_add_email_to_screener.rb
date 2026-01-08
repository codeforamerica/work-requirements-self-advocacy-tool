class AddEmailToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :email, :string
  end
end

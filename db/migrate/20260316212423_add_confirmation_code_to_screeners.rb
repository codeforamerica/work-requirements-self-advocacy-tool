class AddConfirmationCodeToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :confirmation_code, :string
  end
end


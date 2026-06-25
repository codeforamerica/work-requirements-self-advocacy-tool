class AddSessionTokenToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :session_token, :string, null: false, default: ""
    add_index :screeners, :session_token, unique: true
  end
end

class AddSessionTokenToScreeners < ActiveRecord::Migration[7.2]
  def up
    add_column :screeners, :session_token, :string

    execute("UPDATE screeners SET session_token = md5(id::text || random()::text || extract(epoch from clock_timestamp())::text)")

    change_column_null :screeners, :session_token, false
    add_index :screeners, :session_token, unique: true
  end

  def down
    remove_index :screeners, :session_token
    remove_column :screeners, :session_token
  end
end

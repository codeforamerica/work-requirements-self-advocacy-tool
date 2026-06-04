class AddEmailTypeToOutgoingEmails < ActiveRecord::Migration[8.1]
  def change
    add_column :outgoing_emails, :email_type, :integer, null: false, default: 0
    add_index :outgoing_emails, :email_type
  end
end

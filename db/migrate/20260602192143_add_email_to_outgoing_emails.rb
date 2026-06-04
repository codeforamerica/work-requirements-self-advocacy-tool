class AddEmailToOutgoingEmails < ActiveRecord::Migration[8.1]
  def change
    add_column :outgoing_emails, :email, :string
    add_index :outgoing_emails, :email
  end
end

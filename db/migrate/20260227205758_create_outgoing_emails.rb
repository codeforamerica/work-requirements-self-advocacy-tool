class CreateOutgoingEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :outgoing_emails do |t|
      t.belongs_to :screener, null: false
      t.datetime :sent_at

      t.timestamps
    end
  end
end

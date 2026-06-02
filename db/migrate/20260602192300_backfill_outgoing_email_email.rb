class BackfillOutgoingEmailEmail < ActiveRecord::Migration[8.1]
  def change
  end
end

class BackfillOutgoingEmailEmail < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    OutgoingEmail.reset_column_information

    OutgoingEmail.find_each do |outgoing_email|
      outgoing_email.update_columns(
        email: outgoing_email.screener&.email
      )
    end
  end

  def down
    # no-op
  end
end

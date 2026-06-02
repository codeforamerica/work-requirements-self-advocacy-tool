class BackfillOutgoingEmailType < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE outgoing_emails
      SET email_type = CASE
        WHEN screeners.signed_at IS NULL
          OR DATE(outgoing_emails.created_at) = DATE(screeners.signed_at)
          THEN 0
        ELSE 1
      END
      FROM screeners
      WHERE screeners.id = outgoing_emails.screener_id
    SQL
  end

  def down
  end
end

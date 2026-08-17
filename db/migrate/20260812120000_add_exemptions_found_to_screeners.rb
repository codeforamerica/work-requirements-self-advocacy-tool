class AddExemptionsFoundToScreeners < ActiveRecord::Migration[8.1]
  def change
    # Denormalized snapshot of Screener#computed_exemptions, maintained for
    # analytics so exemption logic doesn't have to be reimplemented downstream.
    # NULL means no outcome has been recorded yet; {} means an outcome was
    # recorded and the client had no exemptions.
    add_column :screeners, :exemptions_found, :text, array: true
  end
end

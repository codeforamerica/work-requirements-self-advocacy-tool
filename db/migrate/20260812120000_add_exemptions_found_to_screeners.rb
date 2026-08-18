class AddExemptionsFoundToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :exemptions_found, :text, array: true
  end
end

class AddConsentedToTextsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :consented_to_texts, :integer, null: false, default: 0
  end
end

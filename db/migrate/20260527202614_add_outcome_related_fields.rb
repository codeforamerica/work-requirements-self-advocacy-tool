class AddOutcomeRelatedFields < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :outcome, :string
    add_column :screeners, :outcome_arrived_at, :datetime
    add_column :screeners, :current_step, :string
  end
end

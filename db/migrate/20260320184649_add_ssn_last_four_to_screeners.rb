class AddSsnLastFourToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :ssn_last_four, :string
  end
end

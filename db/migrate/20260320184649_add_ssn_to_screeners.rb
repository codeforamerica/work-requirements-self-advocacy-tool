class AddSsnToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :ssn, :string
  end
end

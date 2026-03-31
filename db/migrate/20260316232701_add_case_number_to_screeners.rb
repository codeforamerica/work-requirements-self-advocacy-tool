class AddCaseNumberToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :case_number, :string
  end
end

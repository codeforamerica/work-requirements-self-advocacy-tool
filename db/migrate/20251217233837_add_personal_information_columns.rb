class AddPersonalInformationColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :screeners, :first_name, :string
    add_column :screeners, :middle_name, :string
    add_column :screeners, :last_name, :string
    add_column :screeners, :birth_date, :date
    add_column :screeners, :phone_number, :string
  end
end

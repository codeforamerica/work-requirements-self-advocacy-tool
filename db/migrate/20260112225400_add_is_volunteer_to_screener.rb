class AddIsVolunteerToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_volunteer, :integer, null: false, default: 0
    add_column :screeners, :volunteering_hours, :integer
    add_column :screeners, :volunteering_org_name, :string
  end
end

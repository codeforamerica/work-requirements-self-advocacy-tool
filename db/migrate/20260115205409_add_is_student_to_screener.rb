class AddIsStudentToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_student, :integer, null: false, default: 0
  end
end

class AddStudentSchoolTypeToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :student_school_type, :integer, null: false, default: 0
  end
end

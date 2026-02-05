class AddAlcoholTreatmentProgramColumnsToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :is_in_alcohol_treatment_program, :integer, null: false, default: 0
    add_column :screeners, :alcohol_treatment_program_name, :string
  end
end

class AddDisabilityBenefitsColumnsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :receiving_benefits_ssdi, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_ssi, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_veterans_disability, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_disability_pension, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_workers_compensation, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_insurance_payments, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_other, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_none, :integer, null: false, default: 0
    add_column :screeners, :receiving_benefits_write_in, :string
  end
end

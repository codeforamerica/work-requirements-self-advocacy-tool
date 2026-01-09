class AddHasUnemploymentBenefitsToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :has_unemployment_benefits, :integer, null: false, default: 0
  end
end

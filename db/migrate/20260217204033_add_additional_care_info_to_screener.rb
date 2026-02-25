class AddAdditionalCareInfoToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :additional_care_info, :text
  end
end

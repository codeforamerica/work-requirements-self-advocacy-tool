class AddPreventingWorkAdditionalInfoToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :preventing_work_additional_info, :text
  end
end

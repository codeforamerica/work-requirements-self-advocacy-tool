class AddVisitorIdToScreeners < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :visitor_id, :string
  end
end

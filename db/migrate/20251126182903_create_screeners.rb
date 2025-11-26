class CreateScreeners < ActiveRecord::Migration[8.0]
  def change
    create_table :screeners do |t|
      t.bigint :language_preference_written, default: 0, null: false
      t.bigint :language_preference_spoken, default: 0, null: false

      t.timestamps
    end
  end
end

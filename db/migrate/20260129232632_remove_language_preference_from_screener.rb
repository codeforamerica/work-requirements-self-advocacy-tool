class RemoveLanguagePreferenceFromScreener < ActiveRecord::Migration[8.1]
  def change
    remove_column :screeners, :language_preference_spoken
    remove_column :screeners, :language_preference_written
  end
end

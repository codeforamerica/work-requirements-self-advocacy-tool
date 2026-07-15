class AddUnsubmittedBecauseColumnsToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :unsubmitted_because_already_reported, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_wont_be_accepted, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_process_too_hard, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_dont_qualify_for_exemptions, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_just_wanted_to_see_result, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_privacy_concerns, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_because_other, :integer, null: false, default: 0
    add_column :screeners, :unsubmitted_write_in, :string
  end
end

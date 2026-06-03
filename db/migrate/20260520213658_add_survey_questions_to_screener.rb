class AddSurveyQuestionsToScreener < ActiveRecord::Migration[8.1]
  def change
    add_column :screeners, :survey_ease_of_experience, :integer, null: false, default: 0

    add_column :screeners, :survey_confidence_in_exemption_rules, :integer, null: false, default: 0

    add_column :screeners, :survey_plan_to_email_results, :integer, null: false, default: 0
    add_column :screeners, :survey_plan_to_submit_results_to_site, :integer, null: false, default: 0
    add_column :screeners, :survey_plan_to_bring_results_to_interview, :integer, null: false, default: 0
    add_column :screeners, :survey_plan_to_bring_results_to_organization, :integer, null: false, default: 0
    add_column :screeners, :survey_plan_to_keep_it_in_records, :integer, null: false, default: 0
    add_column :screeners, :survey_additional_feedback, :text
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_10_222852) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "screeners", force: :cascade do |t|
    t.string "alcohol_treatment_program_name"
    t.date "birth_date"
    t.integer "caring_for_child_under_6", default: 0, null: false
    t.integer "caring_for_disabled_or_ill_person", default: 0, null: false
    t.integer "caring_for_no_one", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.integer "has_child", default: 0, null: false
    t.integer "has_unemployment_benefits", default: 0, null: false
    t.integer "is_american_indian", default: 0, null: false
    t.integer "is_in_alcohol_treatment_program", default: 0, null: false
    t.integer "is_in_work_training", default: 0, null: false
    t.integer "is_migrant_farmworker", default: 0, null: false
    t.integer "is_pregnant", default: 0, null: false
    t.integer "is_student", default: 0, null: false
    t.integer "is_volunteer", default: 0, null: false
    t.integer "is_working", default: 0, null: false
    t.string "last_name"
    t.string "middle_name"
    t.string "phone_number"
    t.date "pregnancy_due_date"
    t.text "preventing_work_additional_info"
    t.integer "preventing_work_domestic_violence", default: 0, null: false
    t.integer "preventing_work_drugs_alcohol", default: 0, null: false
    t.integer "preventing_work_medical_condition", default: 0, null: false
    t.integer "preventing_work_none", default: 0, null: false
    t.integer "preventing_work_other", default: 0, null: false
    t.integer "preventing_work_place_to_sleep", default: 0, null: false
    t.string "preventing_work_write_in"
    t.integer "receiving_benefits_disability_medicaid", default: 0, null: false
    t.integer "receiving_benefits_disability_pension", default: 0, null: false
    t.integer "receiving_benefits_insurance_payments", default: 0, null: false
    t.integer "receiving_benefits_none", default: 0, null: false
    t.integer "receiving_benefits_other", default: 0, null: false
    t.integer "receiving_benefits_ssdi", default: 0, null: false
    t.integer "receiving_benefits_ssi", default: 0, null: false
    t.integer "receiving_benefits_veterans_disability", default: 0, null: false
    t.integer "receiving_benefits_workers_compensation", default: 0, null: false
    t.string "receiving_benefits_write_in"
    t.datetime "updated_at", null: false
    t.integer "volunteering_hours"
    t.string "volunteering_org_name"
    t.string "work_training_hours"
    t.string "work_training_name"
    t.integer "working_hours"
    t.decimal "working_weekly_earnings"
  end
end

class Screener < ApplicationRecord
  attr_accessor :email_confirmation
  enum :language_preference_spoken, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :language_preference_written, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :is_receiving_snap_benefits, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_american_indian, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_volunteer, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :has_child, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_pregnant, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :caring_for_child_under_6, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :caring_for_disabled_or_ill_person, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :caring_for_no_one, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :has_unemployment_benefits, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_ssdi, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_ssi, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_veterans_disability, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_disability_pension, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_workers_compensation, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_insurance_payments, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_other, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_none, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_in_work_training, {unfilled: 0, yes: 1, no: 2}, prefix: true
  attr_writer :birth_date_year, :birth_date_month, :birth_date_day
  attr_writer :pregnancy_due_date_year, :pregnancy_due_date_month, :pregnancy_due_date_day
  normalizes :phone_number, with: ->(value) { Phonelib.parse(value, "US").national }
  before_validation :strip_email_and_confirmation
  before_save :remove_pregnancy_attributes_if_no, :remove_volunteer_attributes_if_no, :remove_work_training_attributes_if_no

  with_context :language_preference do
    validates :language_preference_spoken, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
    validates :language_preference_written, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
  end

  with_context :personal_information do
    validates :first_name, :last_name, :birth_date, :phone_number, presence: true
    validates :phone_number, phone: {possible: true, country_specifier: ->(_) { "US" }, allow_blank: true}
  end

  with_context :receiving_benefits do
    validates :is_receiving_snap_benefits, inclusion: {in: %w[yes no], message: I18n.t("validations.must_answer_yes_or_no")}
  end

  with_context :american_indian do
    validates :is_american_indian, inclusion: {in: %w[yes no], message: I18n.t("validations.must_answer_yes_or_no")}
  end

  with_context :has_child do
    validates :has_child, inclusion: {in: %w[yes no], message: I18n.t("validations.must_answer_yes_or_no")}
  end

  with_context :caring_for_someone do
    validates :caring_for_no_one, inclusion: {in: %w[unfilled no]}, if: -> { caring_for_child_under_6_yes? || caring_for_disabled_or_ill_person_yes? }
  end

  with_context :is_pregnant do
    validates :is_pregnant, inclusion: {in: %w[yes no], message: I18n.t("validations.must_answer_yes_or_no")}
    validates :pregnancy_due_date, comparison: {greater_than: Date.current, message: I18n.t("validations.date_must_be_in_future")}, allow_blank: true
  end

  with_context :has_unemployment_benefits do
    validates :has_unemployment_benefits, inclusion: {in: %w[yes no], message: I18n.t("validations.must_answer_yes_or_no")}
  end

  with_context :disability_benefits do
    validates :receiving_benefits_none, inclusion: {in: %w[unfilled no]},
      if: -> {
        receiving_benefits_ssdi_yes? ||
          receiving_benefits_ssi_yes? ||
          receiving_benefits_veterans_disability_yes? ||
          receiving_benefits_disability_pension_yes? ||
          receiving_benefits_workers_compensation_yes? ||
          receiving_benefits_insurance_payments_yes? ||
          receiving_benefits_other_yes?
      }
    validates :receiving_benefits_write_in, absence: true, if: -> { receiving_benefits_other_no? }
  end

  with_context :email do
    validates :email, "valid_email_2/email": true, confirmation: true
  end

  def locale
    language_preference_written_spanish? ? :es : :en
  end

  def birth_date_year
    birth_date&.year
  end

  def birth_date_month
    birth_date&.month
  end

  def birth_date_day
    birth_date&.day
  end

  def pregnancy_due_date_year
    pregnancy_due_date&.year
  end

  def pregnancy_due_date_month
    pregnancy_due_date&.month
  end

  def pregnancy_due_date_day
    pregnancy_due_date&.day
  end

  def strip_email_and_confirmation
    self.email = email.strip.downcase if email.present?
    self.email_confirmation = email_confirmation.strip.downcase if email_confirmation.present?
  end

  private

  def remove_pregnancy_attributes_if_no
    if is_pregnant_no?
      self.pregnancy_due_date = nil
    end
  end

  def remove_volunteer_attributes_if_no
    if is_volunteer_no?
      self.volunteering_hours = nil
      self.volunteering_org_name = nil
    end
  end

  def remove_work_training_attributes_if_no
    if is_in_work_training_no?
      self.work_training_hours = nil
      self.work_training_name = nil
    end
  end
end

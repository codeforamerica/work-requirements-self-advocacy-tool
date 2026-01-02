class Screener < ApplicationRecord
  enum :language_preference_spoken, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :language_preference_written, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :is_receiving_snap_benefits, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_american_indian, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :has_child, {unfilled: 0, yes: 1, no: 2}, prefix: true
  attr_writer :birth_date_year, :birth_date_month, :birth_date_day
  normalizes :phone_number, with: ->(value) { Phonelib.parse(value, "US").national }

  with_context :language_preference do
    validates :language_preference_spoken, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
    validates :language_preference_written, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
  end

  with_context :personal_information do
    validates :first_name, :last_name, :birth_date, :phone_number, presence: true
    validates :phone_number, phone: true, allow_blank: true
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
end

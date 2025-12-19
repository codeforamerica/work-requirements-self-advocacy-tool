class Screener < ApplicationRecord
  enum :language_preference_spoken, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :language_preference_written, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  attr_writer :birth_date_year, :birth_date_month, :birth_date_day

  with_context :language_preference do
    validates :language_preference_spoken, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
    validates :language_preference_written, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
  end

  with_context :personal_information do
    validates :first_name, presence: true
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

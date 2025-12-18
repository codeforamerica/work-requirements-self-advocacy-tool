class Screener < ApplicationRecord
  enum :language_preference_spoken, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :language_preference_written, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :is_receiving_snap_benefits, {unfilled: 0, yes: 1, no: 2}, prefix: true

  with_context :language_preference do
    validates :language_preference_spoken, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
    validates :language_preference_written, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
  end

  with_context :is_receiving_snap_benefits do
    validates :is_receiving_snap_benefits, inclusion: {in: %w[yes no], message: "must answer yes or no"}
  end

  def locale
    language_preference_written_spanish? ? :es : :en
  end
end

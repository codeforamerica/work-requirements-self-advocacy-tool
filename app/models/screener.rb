class Screener < ApplicationRecord
  enum :language_preference_written, {unfilled: 0, english: 1, spanish: 2}, prefix: true
  enum :language_preference_spoken, {unfilled: 0, english: 1, spanish: 2}, prefix: true

  with_context :language_preference do
    validates :language_preference_spoken, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
    validates :language_preference_written, inclusion: {in: %w[english spanish], message: "must be english or spanish"}
  end
end

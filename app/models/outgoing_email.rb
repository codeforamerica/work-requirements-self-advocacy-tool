class OutgoingEmail < ApplicationRecord
  belongs_to :screener

  enum :email_type, {screener_results: 0, post_results_survey: 1}
end

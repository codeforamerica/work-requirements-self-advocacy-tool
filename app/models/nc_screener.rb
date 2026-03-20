class NcScreener < ApplicationRecord
  belongs_to :screener
  enum :has_hs_diploma, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :worked_last_five_years, {unfilled: 0, yes: 1, no: 2}, prefix: true

  before_save :remove_worked_last_five_years_if_has_diploma

  private

  def remove_worked_last_five_years_if_has_diploma
    if has_hs_diploma_yes?
      self.worked_last_five_years = :unfilled
    end
  end
end

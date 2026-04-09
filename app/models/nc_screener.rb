class NcScreener < ApplicationRecord
  belongs_to :screener
  enum :has_hs_diploma, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :worked_last_five_years, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :teaches_homeschool, {unfilled: 0, yes: 1, no: 2}, prefix: true

  with_context :homeschool do
    validates :homeschool_hours, numericality: {only_integer: true, message: ->(*) { I18n.t("validations.number_invalid") }}, allow_blank: true
  end

  before_save :remove_worked_last_five_years_if_has_diploma,
    :remove_homeschool_attributes_if_no

  def at_least_55_no_diploma_not_working?
    return false unless screener.age

    screener.age >= 55 && has_hs_diploma_no? && worked_last_five_years_no?
  end

  def operating_homeschool_30_or_more_hours?
    teaches_homeschool_yes? && homeschool_hours.to_i >= 30
  end

  def exempt_from_work_rules?
    operating_homeschool_30_or_more_hours? || (at_least_55_no_diploma_not_working? && screener.age <= 64 && screener.preventing_work_medical_condition_yes?)
  end

  private

  def remove_worked_last_five_years_if_has_diploma
    if has_hs_diploma_yes?
      self.worked_last_five_years = :unfilled
    end
  end

  def remove_homeschool_attributes_if_no
    if teaches_homeschool_no?
      self.homeschool_name = nil
      self.homeschool_hours = nil
    end
  end
end

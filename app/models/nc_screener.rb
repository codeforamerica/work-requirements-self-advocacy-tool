class NcScreener < ApplicationRecord
  belongs_to :screener
  enum :has_hs_diploma, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :worked_last_five_years, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :earned_more_than_threshold, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :health_conditions_preventing_work, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :teaches_homeschool, {unfilled: 0, yes: 1, no: 2}, prefix: true

  with_context :homeschool do
    validates :homeschool_hours, numericality: {only_integer: true, message: ->(*) { I18n.t("validations.number_invalid") }}, allow_blank: true
    validates :homeschool_name, length: {maximum:  Nc::HomeschoolController::CHARACTER_LIMIT}
  end

  before_save :remove_work_edu_history_attributes,
    :remove_homeschool_attributes_if_no

  def age_work_education_health_exemption?
    return false unless screener.age

    screener.age.between?(55, 64) &&
      has_hs_diploma_no? &&
      ((worked_last_five_years_yes? && earned_more_than_threshold_no?) || worked_last_five_years_no?) &&
      (health_conditions_preventing_work_yes? || screener.preventing_work_medical_condition_yes?)
  end

  def operating_homeschool_30_or_more_hours?
    teaches_homeschool_yes? && homeschool_hours.to_i >= 30
  end

  def exempt_from_work_rules?
    operating_homeschool_30_or_more_hours? || age_work_education_health_exemption?
  end

  private

  def remove_work_edu_history_attributes
    if has_hs_diploma_yes?
      self.worked_last_five_years = :unfilled
      self.earned_more_than_threshold = :unfilled
      self.health_conditions_preventing_work = :unfilled
    elsif has_hs_diploma_no? && worked_last_five_years_no?
      self.earned_more_than_threshold = :unfilled
      self.health_conditions_preventing_work = :unfilled
    elsif has_hs_diploma_no? && worked_last_five_years_yes? && earned_more_than_threshold_yes?
      self.health_conditions_preventing_work = :unfilled
    end
  end

  def remove_homeschool_attributes_if_no
    if teaches_homeschool_no?
      self.homeschool_name = nil
      self.homeschool_hours = nil
    end
  end
end

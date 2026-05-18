class Screener < ApplicationRecord
  devise :timeoutable

  BASIC_INFO_DETAILS_CHARACTER_LIMIT = 19
  BASIC_INFO_EMAIL_CHARACTER_LIMIT = 60

  has_many :outgoing_emails, dependent: :destroy
  has_one :nc_screener, dependent: :destroy

  attr_accessor :email_confirmation
  attr_accessor :from_download_form
  attr_writer :birth_date_year, :birth_date_month, :birth_date_day
  attr_writer :pregnancy_due_date_year, :pregnancy_due_date_month, :pregnancy_due_date_day

  encrypts :ssn_last_four

  enum :caring_for_child_under_6, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :caring_for_disabled_or_ill_person, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :caring_for_no_one, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :consented_to_texts, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :has_child, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :has_unemployment_benefits, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_american_indian, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_in_alcohol_treatment_program, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_in_work_training, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_migrant_farmworker, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_pregnant, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_student, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_working, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :is_volunteer, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_drugs_alcohol, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_domestic_violence, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_medical_condition, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_none, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_other, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :preventing_work_place_to_sleep, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_disability_pension, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_disability_medicaid, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_insurance_payments, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_other, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_none, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_ssdi, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_ssi, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_veterans_disability, {unfilled: 0, yes: 1, no: 2}, prefix: true
  enum :receiving_benefits_workers_compensation, {unfilled: 0, yes: 1, no: 2}, prefix: true

  normalizes :phone_number, with: ->(value) { Phonelib.parse(value, "US").national }
  before_validation :strip_email_and_confirmation
  before_save :remove_additional_care_info_if_caring_for_someone_is_no,
    :remove_alcohol_treatment_program_attributes_if_no,
    :remove_county_if_state_does_not_require,
    :remove_employment_attributes_if_no,
    :remove_pregnancy_attributes_if_no,
    :remove_preventing_working_info_if_no_reasons,
    :remove_training_program_attributes_if_no,
    :remove_volunteer_attributes_if_no,
    :remove_zip_code_if_state_does_not_require

  with_context :alcohol_treatment_program do
    validates :alcohol_treatment_program_name, length: {maximum: AlcoholTreatmentProgramController::CHARACTER_LIMIT}
  end

  with_context :american_indian do
    validates :is_american_indian, inclusion: {in: %w[yes no], message: ->(*) { I18n.t("validations.must_answer_yes_or_no") }}
  end

  with_context :basic_info_email do
    validates :email,
      "valid_email_2/email": {message: ->(*) { I18n.t("validations.email_invalid") }},
      if: -> { email.present? }

    validates :email, length: {maximum: BASIC_INFO_EMAIL_CHARACTER_LIMIT}

    validates :email,
      presence: {message: ->(*) { I18n.t("validations.email_invalid") }},
      if: -> { from_download_form }

    validates :email_confirmation,
      presence: {message: ->(*) { I18n.t("validations.email_confirmation_required") }},
      if: -> { from_download_form || email.present? }

    validates :email,
      confirmation: {message: ->(*) { I18n.t("validations.email_must_match") }},
      if: -> { email.present? || email_confirmation.present? }
  end

  with_context :basic_info_details do
    validates :first_name, presence: {message: ->(*) { I18n.t("validations.first_name_required") }}
    validates :first_name, length: {maximum: BASIC_INFO_DETAILS_CHARACTER_LIMIT}
    validates :last_name, presence: {message: ->(*) { I18n.t("validations.last_name_required") }}
    validates :last_name, length: {maximum: BASIC_INFO_DETAILS_CHARACTER_LIMIT}
    validates :middle_name, length: {maximum: BASIC_INFO_DETAILS_CHARACTER_LIMIT}
    validates :phone_number, phone: {possible: true, country_specifier: ->(_) { "US" }, allow_blank: true, message: ->(*) { I18n.t("validations.phone_invalid") }}
    validates :birth_date, presence: {message: ->(*) { I18n.t("validations.date_missing_or_invalid") }}
  end

  with_context :basic_info_ssn do
    validates :ssn_last_four, format: {with: /\A\d{4}\z/}, allow_blank: true
  end

  with_context :caring_for_someone do
    validates :caring_for_no_one, inclusion: {in: %w[unfilled no]}, if: -> { caring_for_child_under_6_yes? || caring_for_disabled_or_ill_person_yes? }
    validates :additional_care_info, length: {maximum: CaringForSomeoneController::CHARACTER_LIMIT}
  end

  with_context :community_service do
    validates :volunteering_hours, numericality: {only_integer: true, message: ->(*) { I18n.t("validations.number_invalid") }}, allow_blank: true
  end

  with_context :date_of_birth do
    validates :birth_date, presence: {message: ->(*) { I18n.t("validations.date_missing_or_invalid") }}
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
          receiving_benefits_disability_medicaid_yes? ||
          receiving_benefits_other_yes?
      }
    validates :receiving_benefits_write_in, absence: true, if: -> { receiving_benefits_other_no? }
  end

  with_context :employment do
    validates :working_hours, numericality: {only_integer: true, message: ->(*) { I18n.t("validations.number_invalid") }}, allow_blank: true
    validates :working_weekly_earnings, numericality: {only_decimal: true, message: ->(*) { I18n.t("validations.amount_invalid") }}, allow_blank: true
  end

  with_context :location do
    validates :state, inclusion: {in: LocationData::States.active_states.keys + [LocationData::States::NOT_LISTED]}

    validates :county,
      inclusion: {
        in: ->(record) { LocationData::Counties.for_state(record.state).keys }
      },
      if: ->(record) { LocationData::Counties.for_state(record.state).present? }

    validates :zip_code,
      inclusion: {
        in: ->(record) { LocationData::ZipCodes.for_state(record.state).keys },
        message: ->(*) { I18n.t("validations.zip_code_invalid") }
      },
      if: ->(record) { LocationData::ZipCodes.for_state(record.state).present? }
  end

  with_context :living_with_someone do
    validates :has_child, inclusion: {in: %w[yes no], message: ->(*) { I18n.t("validations.must_answer_yes_or_no") }}
  end

  with_context :pregnancy do
    validates :pregnancy_due_date,
      comparison: {
        greater_than: Date.current,
        message: ->(*) { I18n.t("validations.date_must_be_in_future") }
      },
      allow_blank: true
  end

  with_context :preventing_work_details do
    validates :preventing_work_additional_info, length: {maximum: PreventingWorkDetailsController::CHARACTER_LIMIT}
  end

  with_context :preventing_work_situations do
    validates :preventing_work_none, inclusion: {in: %w[unfilled no]},
      if: -> {
        preventing_work_place_to_sleep_yes? ||
          preventing_work_drugs_alcohol_yes? ||
          preventing_work_domestic_violence_yes? ||
          preventing_work_medical_condition_yes? ||
          preventing_work_other_yes?
      }
    validates :preventing_work_write_in, absence: true, if: -> { preventing_work_other_no? }
    validates :preventing_work_write_in, length: {maximum: PreventingWorkSituationsController::CHARACTER_LIMIT}
  end

  with_context :school_enrollment do
    validates :is_student, inclusion: {in: %w[yes no], message: ->(*) { I18n.t("validations.must_answer_yes_or_no") }}
  end

  with_context :signature do
    validates :signature, presence: {message: ->(*) { I18n.t("validations.signature_required") }}
  end

  with_context :training_program do
    validates :work_training_hours, numericality: {only_integer: true, message: ->(*) { I18n.t("validations.number_invalid") }}, allow_blank: true
  end

  with_context :unemployment do
    validates :has_unemployment_benefits, inclusion: {in: %w[yes no], message: ->(*) { I18n.t("validations.must_answer_yes_or_no") }}
  end

  DISABILITY_BENEFIT_ATTRIBUTES = %i[
    receiving_benefits_ssdi
    receiving_benefits_ssi
    receiving_benefits_veterans_disability
    receiving_benefits_workers_compensation
    receiving_benefits_disability_pension
    receiving_benefits_insurance_payments
    receiving_benefits_disability_medicaid
    receiving_benefits_other
  ].freeze

  PREVENTING_WORK_ATTRIBUTES = %i[
    preventing_work_domestic_violence
    preventing_work_drugs_alcohol
    preventing_work_medical_condition
    preventing_work_other
    preventing_work_place_to_sleep
  ].freeze

  OTHER_EXEMPTION_ATTRIBUTES = %i[
    caring_for_child_under_6
    caring_for_disabled_or_ill_person
    has_child
    has_unemployment_benefits
    is_american_indian
    is_in_alcohol_treatment_program
    is_migrant_farmworker
    is_pregnant
    is_student
  ].freeze

  ELIGIBILITY_EXEMPTION_ATTRIBUTES = DISABILITY_BENEFIT_ATTRIBUTES + PREVENTING_WORK_ATTRIBUTES + OTHER_EXEMPTION_ATTRIBUTES

  def age
    return nil unless birth_date
    today = Date.current
    a = today.year - birth_date.year
    a -= 1 if today < birth_date + a.years
    a
  end

  def age_qualified?
    return false unless age
    age <= 17 || age >= 65
  end

  def any_preventing_work?
    PREVENTING_WORK_ATTRIBUTES.any? { |attr| public_send("#{attr}_yes?") } ||
      state == LocationData::States::NORTH_CAROLINA && nc_screener.present? && nc_screener.age_work_education_health_exemption?
  end

  def birth_date_day
    birth_date&.day
  end

  def birth_date_month
    birth_date&.month
  end

  def birth_date_year
    birth_date&.year
  end

  def complies_with_work_rules?
    total_work_volunteer_and_training_hours >= 20
  end

  def earnings_above_minimum?
    working_weekly_earnings.to_f >= 217.50
  end

  def exempt_from_state_work_rules?
    case state
    when LocationData::States::NORTH_CAROLINA
      nc_screener.present? && nc_screener.exempt_from_work_rules?
    else
      false
    end
  end

  def exempt_from_work_rules?
    has_exemption? || has_earnings_exemption?
  end

  def has_earnings_exemption?
    is_working_yes? && (working_30_or_more_hours? || earnings_above_minimum?)
  end

  def has_exemption?
    return true if age_qualified?
    return true if exempt_from_state_work_rules?

    ELIGIBILITY_EXEMPTION_ATTRIBUTES.any? do |attribute|
      public_send("#{attribute}_yes?")
    end
  end

  def pdf
    LocationData::States.pdf_filler_class(state).new(self).combined_pdf
  end

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def full_name_with_middle
    [first_name, middle_name.presence, last_name].compact.join(" ")
  end

  def office_info_for(attribute)
    case LocationData::States::STATES_INFO[state][:office_by]
    when :county
      LocationData::Counties.get(state, county)[attribute]
    else
      raise StandardError, "Cannot return office for zip #{zip_code}" if office_or_offices_for_zip.is_a?(Array)

      office_or_offices_for_zip[attribute]
    end
  end

  def office_or_offices_for_zip
    possible_offices = LocationData::ZipCodes.get_all(state, zip_code)
    if possible_offices.length == 1
      possible_offices.first
    else
      # if zip code is divided geographically, we don't know which office to send them to and must return all of them
      return possible_offices if possible_offices.any? { |office| office[:special_geo] }.present?

      # if there are multiple offices and they are not "special geo", it means they are divided by last name
      return unless last_name.present?
      range = "A".."Smh"
      if range.cover?(last_name.capitalize)
        possible_offices.find { |office| office[:last_names_a_smh] }
      else
        possible_offices.find { |office| office[:last_names_smi_z] }
      end
    end
  end

  def office_email
    office_info_for(:email)
  end

  def office_mailing_address
    office_info_for(:mailing_address)
  end

  def office_name
    office_info_for(:name)
  end

  def office_phone
    office_info_for(:phone)
  end

  def office_physical_address
    office_info_for(:physical_address) || office_mailing_address
  end

  def office_upload_or_portal_email
    office_info_for(:upload_portal_or_email) || office_email
  end

  def office_website
    office_info_for(:website)
  end

  def pregnancy_due_date_day
    pregnancy_due_date&.day
  end

  def pregnancy_due_date_month
    pregnancy_due_date&.month
  end

  def pregnancy_due_date_year
    pregnancy_due_date&.year
  end

  def receiving_disability_benefits?
    DISABILITY_BENEFIT_ATTRIBUTES.any? { |attr| public_send("#{attr}_yes?") }
  end

  def requires_proof?
    (earnings_above_minimum? && !exempt_from_work_rules?) ||
      is_student_yes? ||
      preventing_work_drugs_alcohol_yes? ||
      preventing_work_medical_condition_yes? ||
      receiving_disability_benefits? ||
      is_in_alcohol_treatment_program_yes?
  end

  def strip_email_and_confirmation
    self.email = email.strip.downcase if email.present?
    self.email_confirmation = email_confirmation.strip.downcase if email_confirmation.present?
  end

  def total_work_volunteer_and_training_hours
    working_hours.to_i + volunteering_hours.to_i + work_training_hours.to_i
  end

  def volunteering?
    is_volunteer_yes? && volunteering_hours.to_i > 0
  end

  def needs_proof_of_volunteering?
    state != LocationData::States::NORTH_CAROLINA && volunteering?
  end

  def working_30_or_more_hours?
    working_hours.to_i >= 30
  end

  private

  def remove_county_if_state_does_not_require
    self.county = nil unless state.present? && LocationData::Counties.for_state(state).present?
  end

  def remove_additional_care_info_if_caring_for_someone_is_no
    if caring_for_child_under_6_no? && caring_for_disabled_or_ill_person_no?
      self.additional_care_info = nil
    end
  end

  def remove_pregnancy_attributes_if_no
    if is_pregnant_no?
      self.pregnancy_due_date = nil
    end
  end

  def remove_employment_attributes_if_no
    if is_working_no?
      self.working_hours = nil
      self.working_weekly_earnings = nil
    end
  end

  def remove_volunteer_attributes_if_no
    if is_volunteer_no?
      self.volunteering_hours = nil
      self.volunteering_org_name = nil
    end
  end

  def remove_training_program_attributes_if_no
    if is_in_work_training_no?
      self.work_training_hours = nil
      self.work_training_name = nil
    end
  end

  def remove_alcohol_treatment_program_attributes_if_no
    if is_in_alcohol_treatment_program_no?
      self.alcohol_treatment_program_name = nil
    end
  end

  def remove_preventing_working_info_if_no_reasons
    self.preventing_work_additional_info = nil if preventing_work_none_yes? || (preventing_work_place_to_sleep_no? && preventing_work_drugs_alcohol_no? && preventing_work_domestic_violence_no? && preventing_work_medical_condition_no? && preventing_work_other_no?)
  end

  def remove_zip_code_if_state_does_not_require
    self.zip_code = nil unless state.present? && LocationData::ZipCodes.for_state(state).present?
  end
end

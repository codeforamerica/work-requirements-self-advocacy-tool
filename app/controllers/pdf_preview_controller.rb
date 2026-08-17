class PdfPreviewController < QuestionController
  layout "pdf"
  skip_before_action :require_current_screener
  skip_before_action :set_screener_current_step_and_locale
  before_action :build_temp_screener

  def build_temp_screener
    @temp_screener ||= Screener.new(
      state: LocationData::States::NORTH_CAROLINA,
      first_name: "José",
      middle_name: "María",
      last_name: "Muñoz",
      birth_date: Date.new(1968, 3, 6),
      email: "testy@example.com",
      phone_number: "9195550123",
      case_number: "123456789",
      ssn_last_four: "1234",
      confirmation_code: "ABC123",
      signature: "José María Muñoz",
      is_american_indian: "yes",
      has_child: "yes",
      caring_for_child_under_6: "yes",
      caring_for_disabled_or_ill_person: "yes",
      additional_care_info: "Caring for my elderly mother",
      is_pregnant: "yes",
      pregnancy_due_date: Date.new(2026, 9, 15),
      has_unemployment_benefits: "yes",
      receiving_benefits_ssdi: "yes",
      receiving_benefits_ssi: "yes",
      receiving_benefits_veterans_disability: "yes",
      receiving_benefits_workers_compensation: "yes",
      receiving_benefits_disability_pension: "yes",
      receiving_benefits_insurance_payments: "yes",
      receiving_benefits_disability_medicaid: "yes",
      receiving_benefits_other: "yes",
      receiving_benefits_write_in: "Short-term disability from employer",
      is_working: "yes",
      working_hours: 35,
      working_weekly_earnings: 250.00,
      is_volunteer: "yes",
      volunteering_hours: 10,
      volunteering_org_name: "Muffins for Mums",
      is_in_work_training: "yes",
      work_training_name: "Bake Off Boot Camp",
      work_training_hours: "15",
      is_student: "yes",
      is_migrant_farmworker: "yes",
      is_in_alcohol_treatment_program: "yes",
      alcohol_treatment_program_name: "Recovery Program",
      preventing_work_place_to_sleep: "yes",
      preventing_work_domestic_violence: "yes",
      preventing_work_drugs_alcohol: "yes",
      preventing_work_medical_condition: "yes",
      preventing_work_other: "yes",
      preventing_work_write_in: "Chronic back pain",
      preventing_work_additional_info: "I experience severe pain that limits how long I can stand or sit."
    )
    @temp_screener.build_nc_screener(
      has_hs_diploma: "no",
      worked_last_five_years: "no",
      teaches_homeschool: "yes",
      homeschool_hours: 32,
      homeschool_name: "Small Fry Homeschool Co-op"
    )
  end

  def summary_page
    render template: "pdf/summary_page", locals: temp_screener_packet_pdf.hash_for_generated_pdf
  end

  def packet
    send_data temp_screener_packet_pdf.combined_pdf_all_html, filename: "packet_preview.pdf", disposition: "inline"
  end

  private
  def temp_screener_packet_pdf
    LocationData::States.pdf_filler_class(@temp_screener.state).new(@temp_screener)
  end
end

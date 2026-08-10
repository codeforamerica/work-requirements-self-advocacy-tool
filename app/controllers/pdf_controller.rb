class PdfController < QuestionController
  layout "pdf"
  skip_before_action :set_screener_current_step_and_locale
  # These preview actions render against the fixed @temp_screener below, not a real signed-in
  # screener, so they don't need an active session -- unlike generate_pdf, the real download path.
  skip_before_action :require_current_screener, only: [:summary_page, :filled_packet_preview, :combined_pdf_preview]
  before_action :build_temp_screener

  def build_temp_screener
    @temp_screener ||= Screener.new(
      state: LocationData::States::NORTH_CAROLINA,
      first_name: "José",
      middle_name: "María",
      last_name: "Muñoz",
      birth_date: Date.new(1960, 3, 6),
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
    @temp_screener.build_nc_screener(has_hs_diploma: "no", worked_last_five_years: "no")
  end

  def generate_pdf
    send_mixpanel_event(event_name: "pdf_downloaded")
    send_data current_screener.pdf, filename: "combined.pdf", disposition: "inline"
  end

  def summary_page
    render :summary_page, locals: temp_screener_packet_pdf.hash_for_generated_pdf
  end

  # SPIKE (WRSAT-687): preview of the filled packet rendered as HTML instead
  # of filling packet.pdf's AcroForm fields.
  def filled_packet_preview
    render "pdf/filled_packet", locals: temp_screener_packet_pdf.hash_for_fillable_pdf.merge(state: @temp_screener.state)
  end

  # SPIKE (WRSAT-687): preview of the actual generated PDF (combined_pdf_all_html) against the
  # fixed test screener above, so it can be viewed by just visiting this URL instead of having to
  # walk through the whole screener flow after every change.
  def combined_pdf_preview
    send_data temp_screener_packet_pdf.combined_pdf_all_html, filename: "combined_preview.pdf", disposition: "inline"
  end

  private

  # Mirrors Screener#pdf's state-based class selection, so previews reflect the
  # same NC/DE-specific behavior (e.g. NcPacketPdf's extra fields) as production.
  def temp_screener_packet_pdf
    LocationData::States.pdf_filler_class(@temp_screener.state).new(@temp_screener)
  end
end

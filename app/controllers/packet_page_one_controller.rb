class PacketPageOneController < QuestionController
  layout "pdf"
  before_action :build_temp_screener

  def build_temp_screener
    @temp_screener ||= Screener.new(
      state: LocationData::States::NORTH_CAROLINA,
      first_name: "Testy",
      middle_name: "Mary",
      last_name: "Testerson",
      birth_date: Date.new(1960, 3, 6),
      email: "testy@example.com",
      phone_number: "9195550123",
      is_american_indian: "yes",
      has_child: "yes",
      caring_for_child_under_6: "yes",
      caring_for_disabled_or_ill_person: "yes",
      additional_care_info: "Caring for my elderly mother",
      is_pregnant: "yes",
      pregnancy_due_date: Date.new(2026, 9, 15),
      has_unemployment_benefits: "yes",
      receiving_benefits_ssdi: "yes",
      receiving_benefits_veterans_disability: "yes",
      is_working: "yes",
      working_hours: 35,
      working_weekly_earnings: 250.00,
      is_volunteer: "yes",
      volunteering_hours: 10,
      volunteering_org_name: "Local Food Bank",
      is_in_work_training: "yes",
      work_training_name: "Job Corps",
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
      preventing_work_write_in: "Chronic back pain"
    )
    @temp_screener.build_nc_screener(has_hs_diploma: "no", worked_last_five_years: "no")
  end

  def generate_pdf
    send_data PdfFiller::PacketPdf.new(@temp_screener).combined_pdf, filename: "combined.pdf", disposition: "inline"
  end

  def page
    render :page, locals: PdfFiller::PacketPdf.new(@temp_screener).hash_for_generated_pdf
  end
end

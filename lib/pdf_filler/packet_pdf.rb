module PdfFiller
  class PacketPdf
    def initialize(screener)
      @screener = screener
    end

    def hash_for_fillable_pdf
      shared_fields.merge(
        age: @screener.age.to_s,
        # case_number: "",
        # confirmation_code: "",
        details_of_care: @screener.additional_care_info,
        drug_alcohol_program_name: @screener.alcohol_treatment_program_name,
        earnings_per_week: @screener.working_weekly_earnings.to_s,
        email: @screener.email,
        full_name_with_middle: @screener.full_name_with_middle,
        # homeschool_hours: "",
        # homeschool_name: "",
        is_in_work_training: @screener.is_in_work_training_yes?,
        is_volunteering: @screener.volunteering?,
        # operating_a_homeschool: "",
        phone_number: @screener.phone_number,
        preventing_work_write_in: @screener.preventing_work_write_in,
        receiving_benefits_disability_medicaid: @screener.receiving_benefits_disability_medicaid_yes?,
        receiving_benefits_disability_pension: @screener.receiving_benefits_disability_pension_yes?,
        receiving_benefits_insurance_payments: @screener.receiving_benefits_insurance_payments_yes?,
        receiving_benefits_other: @screener.receiving_benefits_other_yes?,
        receiving_benefits_ssdi: @screener.receiving_benefits_ssdi_yes?,
        receiving_benefits_ssi: @screener.receiving_benefits_ssi_yes?,
        receiving_benefits_veterans_disability: @screener.receiving_benefits_veterans_disability_yes?,
        receiving_benefits_workers_compensation: @screener.receiving_benefits_workers_compensation_yes?,
        receiving_benefits_write_in: @screener.receiving_benefits_write_in,
        receiving_disabilty_benefits: @screener.receiving_disability_benefits?,
        signature: @screener.full_name_with_middle,
        # ssn_last_4: "",
        submission_date: submission_date,
        submission_date_2: submission_date,
        volunteering_hours: @screener.volunteering_hours.to_s,
        volunteering_org_name: @screener.volunteering_org_name,
        work_hours: @screener.working_hours.to_s,
        work_training_name: @screener.work_training_name,
        working_or_earning: @screener.working_exempt?
      )
    end

    def hash_for_generated_pdf
      shared_fields.merge(
        any_preventing_work: @screener.any_preventing_work?,
        earnings_above_minimum: @screener.earnings_above_minimum?,
        full_name: @screener.full_name,
        receiving_disability_benefits: @screener.receiving_disability_benefits?,
        volunteering_hours: @screener.volunteering_hours.to_i,
        weekly_earnings: @screener.working_weekly_earnings.to_f,
        work_hours: @screener.working_hours.to_i,
        work_training_hours: @screener.work_training_hours.to_i,
        working_30_or_more_hours: @screener.working_30_or_more_hours?
      )
    end

    def filled_pdf_path
      source_pdf_path = case @screener.state
      when LocationData::States::NORTH_CAROLINA
        "app/assets/pdfs/nc_packet.pdf"
      else
        "app/assets/pdfs/packet.pdf"
      end
      template_doc = HexaPDF::Document.open(source_pdf_path)
      hash_for_fillable_pdf.each do |field_name, field_value|
        template_doc.acro_form.field_by_name(field_name.to_s).field_value = field_value
      end
      pdf_tempfile = Tempfile.new(["packet", ".pdf"], "tmp/")
      template_doc.write(pdf_tempfile)
      pdf_tempfile.path
    end

    def generated_pdf_path
      html = PacketPageOneController.new.render_to_string(
        {
          template: "packet_page_one/page",
          layout: "pdf",
          locals: hash_for_generated_pdf
        }
      )
      css_path = Rails.root.join("app", "assets", "stylesheets", "wr_exemption_pdf.css")
      style_tag_options = [{path: css_path}]
      path = "tmp/page_1#{SecureRandom.uuid}.pdf"
      Grover.new(html, style_tag_options: style_tag_options, print_background: true).to_pdf(path)
      path
    end

    def combined_pdf
      target = HexaPDF::Document.new
      [generated_pdf_path, filled_pdf_path].each do |file|
        pdf = HexaPDF::Document.open(file)
        pdf.pages.each { |page| target.pages << target.import(page) }
      end
      target.write_to_string
    ensure
      File.delete(generated_pdf_path) # not a Tempfile so we have to manually delete it
    end

    private

    def shared_fields
      {
        at_least_55_no_diploma_not_working: @screener.nc_screener.at_least_55_no_diploma_not_working?,
        birth_date: @screener.birth_date.to_s,
        caring_for_child_under_6: @screener.caring_for_child_under_6_yes?,
        caring_for_disabled_or_ill_person: @screener.caring_for_disabled_or_ill_person_yes?,
        enrolled_in_education: @screener.is_student_yes?,
        has_child: @screener.has_child_yes?,
        has_unemployment_benefits: @screener.has_unemployment_benefits_yes?,
        in_drug_or_alcohol_program: @screener.is_in_alcohol_treatment_program_yes?,
        is_american_indian: @screener.is_american_indian_yes?,
        is_pregnant: @screener.is_pregnant_yes?,
        pregnancy_due_date: @screener.pregnancy_due_date.to_s,
        preventing_work_domestic_violence: @screener.preventing_work_domestic_violence_yes?,
        preventing_work_drugs_alcohol: @screener.preventing_work_drugs_alcohol_yes?,
        preventing_work_medical_condition: @screener.preventing_work_medical_condition_yes?,
        preventing_work_other: @screener.preventing_work_other_yes?,
        preventing_work_place_to_sleep: @screener.preventing_work_place_to_sleep_yes?,
        seasonal_worker: @screener.is_migrant_farmworker_yes?,
        volunteering_hours: @screener.volunteering_hours,
        work_hours: @screener.working_hours,
        work_training_hours: @screener.work_training_hours
      }
    end

    def submission_date
      Date.current.to_s
    end
  end
end

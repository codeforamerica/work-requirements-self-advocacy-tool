module PdfFiller
  class PacketPdf
    def initialize(screener)
      @screener = screener
    end

    def yes_no_unfilled_to_checkbox(value)
      (value == "yes") ? "Yes" : "Off"
    end

    def hash_for_pdf
      {
        full_name: @screener.full_name,
        general_work_requirements_exemptions: "",
        abawd_work_requirements_exemptions: "",
        abawd_work_requirement_compliance: "",
        confirmation_code: "",
        full_name_with_middle: @screener.full_name_with_middle,
        birth_date: @screener.birth_date,
        birth_date_2: @screener.birth_date,
        email: @screener.email,
        phone_number: @screener.phone_number,
        case_number: "",
        ssn_last_4: "",
        age: "",
        is_american_indian: yes_no_unfilled_to_checkbox(@screener.is_american_indian),
        has_child: "",
        caring_for_child_under_6: "",
        caring_for_disabled_or_ill_person: "",
        is_pregnant: "",
        is_in_work_training: "",
        work_training_name: "",
        work_training_hours: "",
        has_unemployment_benefits: "",
        receiving_disabilty_benefits: "",
        receiving_benefits_ssdi: "",
        receiving_benefits_ssi: "",
        receiving_benefits_veterans_disability: "",
        receiving_benefits_workers_compensation: "",
        receiving_benefits_disability_pension: "",
        receiving_benefits_insurance_payments: "",
        receiving_benefits_disability_medicaid: "",
        receiving_benefits_other: "",
        receiving_benefits_write_in: "",
        details_of_care: "",
        pregnancy_due_date: "",
        working_or_earning: "",
        seasonal_worker: "",
        is_volunteering: "",
        work_hours: "",
        earnings_per_week: "",
        volunteering_hours: "",
        volunteering_org_name: "",
        enrolled_in_education: "",
        in_drug_or_alcohol_program: "",
        preventing_work_place_to_sleep: "",
        preventing_work_drugs_alcohol: "",
        preventing_work_domestic_violence: "",
        preventing_work_medical_condition: "",
        preventing_work_other: "",
        drug_alcohol_program_name: "",
        preventing_work_write_in: "",
        signature: "",
        submission_date: "",
        submission_date_2: ""
      }
    end

    def filled_pdf
      source_pdf_name = "packet"
      source_pdf_path = "app/assets/pdfs/#{source_pdf_name}.pdf"
      pdf_tempfile = Tempfile.new(
        [source_pdf_name, ".pdf"],
        "tmp/"
      )
      PdfForms.new.fill_form(source_pdf_path, pdf_tempfile.path, hash_for_pdf)
      pdf_tempfile
    end

    def html_to_pdf
      html = TempEndController.new.render_to_string({template: "packet_page_one/page", layout: "pdf"})
      Grover.new(html).to_pdf
    end

    def combined_pdf
      page_1 = CombinePDF.parse(html_to_pdf)
      packet = CombinePDF.load(filled_pdf.path)
      page_1 << packet
      page_1.to_pdf
    end
  end
end

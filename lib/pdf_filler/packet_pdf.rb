module PdfFiller
  class PacketPdf
    def initialize(screener)
      @screener = screener
    end

    def yes_no_unfilled_to_checkbox(value)
      value == "yes"
    end

    # TODO: remove page one of the fillable PDF
    GEN_WOR_REQ = <<~BLOCK
      General Work Requirement Exemptions\r
      \u2022 Caring for a child under 6 years old - 7 CFR 273.7(b)(1)(iv)
      • Caring for an incapacitated person - 7 CFR 273.7(b)(1)(iv)
      Currently getting unemployment benefits or has applied for unemployment benefits - 7 CFR 273.7(b)(1)(v)
      Participating regularly in an alcohol or drug treatment program - 7 CFR 273.24(c)(2)
      Enrolled in a school, training program, or institution of higher education at least half-time - 7 CFR 273.7(b)(1)(viii)
      Working at least 30 hours a week - 7 CFR 273.7(b)(1)(vii)
      Earning at least $217.50 a week, averaged monthly, from work - 7 CFR 273.7(b)(1)(vii)
    BLOCK

    # TODO: finish the hash
    def hash_for_pdf
      {
        full_name: @screener.full_name,
        general_work_requirements_exemptions: GEN_WOR_REQ,
        # abawd_work_requirements_exemptions: "",
        # abawd_work_requirement_compliance: "",
        # confirmation_code: "",
        full_name_with_middle: @screener.full_name_with_middle,
        birth_date: @screener.birth_date.to_s,
        birth_date_2: @screener.birth_date.to_s,
        email: @screener.email,
        phone_number: @screener.phone_number,
        # case_number: "",
        # ssn_last_4: "",
        # age: "",
        is_american_indian: yes_no_unfilled_to_checkbox(@screener.is_american_indian),
        # has_child: "",
        caring_for_child_under_6: yes_no_unfilled_to_checkbox(@screener.caring_for_child_under_6),
        # caring_for_disabled_or_ill_person: "",
        # is_pregnant: "",
        # is_in_work_training: "",
        # work_training_name: "",
        # work_training_hours: "",
        # has_unemployment_benefits: "",
        # receiving_disabilty_benefits: "",
        # receiving_benefits_ssdi: "",
        # receiving_benefits_ssi: "",
        # receiving_benefits_veterans_disability: "",
        # receiving_benefits_workers_compensation: "",
        # receiving_benefits_disability_pension: "",
        # receiving_benefits_insurance_payments: "",
        # receiving_benefits_disability_medicaid: "",
        # receiving_benefits_other: "",
        # receiving_benefits_write_in: "",
        # details_of_care: "",
        # pregnancy_due_date: "",
        # working_or_earning: "",
        # seasonal_worker: "",
        # is_volunteering: "",
        # work_hours: "",
        # earnings_per_week: "",
        # volunteering_hours: "",
        # volunteering_org_name: "",
        # enrolled_in_education: "",
        # in_drug_or_alcohol_program: "",
        # preventing_work_place_to_sleep: "",
        # preventing_work_drugs_alcohol: "",
        # preventing_work_domestic_violence: "",
        # preventing_work_medical_condition: "",
        # preventing_work_other: "",
        # drug_alcohol_program_name: "",
        # preventing_work_write_in: "",
        # signature: "",
        # submission_date: "",
        # submission_date_2: ""
      }
    end

    def filled_pdf
      source_pdf_path = "app/assets/pdfs/packet.pdf"
      template_doc = HexaPDF::Document.open(source_pdf_path)
      hash_for_pdf.each do |field_name, field_value|
        template_doc.acro_form.field_by_name(field_name.to_s).field_value = field_value
      end
      pdf_tempfile = Tempfile.new(
        ["packet", ".pdf"],
        "tmp/"
      )
      template_doc.write(pdf_tempfile)
      pdf_tempfile
    end

    def generated_pdf_path
      html = PacketPageOneController.new.render_to_string(
        {
          template: "packet_page_one/page",
          layout: "pdf",
          locals: hash_for_pdf
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
      [generated_pdf_path, filled_pdf.path].each do |file|
        pdf = HexaPDF::Document.open(file)
        pdf.pages.each {|page| target.pages << target.import(page)}
      end

      target.write_to_string
    ensure
      File.delete(generated_pdf_path) # not a Tempfile so we have to manually delete it
    end
  end
end

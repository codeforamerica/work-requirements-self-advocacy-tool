module PdfFiller
  class PacketPdf
    def initialize(screener)
      @screener = screener
    end

    def filled_pdf_source
      if @screener.has_exemption?
        "app/assets/pdfs/packet--no-income.pdf"
      elsif @screener.has_earnings_exemption?
        "app/assets/pdfs/packet.pdf"
      end
    end

    def generated_pdf_template
      "pdf/summary_page"
    end

    def hash_for_fillable_pdf
      fields = shared_fields.merge(
        age: @screener.age.to_s,
        case_number: @screener.case_number,
        confirmation_code: @screener.confirmation_code,
        details_of_care: @screener.additional_care_info,
        drug_alcohol_program_name: @screener.alcohol_treatment_program_name,
        email: @screener.email,
        full_name_with_middle: @screener.full_name_with_middle,
        phone_number: @screener.phone_number,
        preventing_work_write_in: @screener.preventing_work_additional_info,
        preventing_work_other_write_in: @screener.preventing_work_write_in,
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
        signature: @screener.signature,
        ssn_last_4: @screener.ssn_last_four,
        submission_date: submission_date
      )
      if @screener.has_earnings_exemption?
        fields.merge!(
          earnings_per_week: @screener.working_weekly_earnings.to_s,
          is_in_work_training: @screener.is_in_work_training_yes?,
          is_volunteering: @screener.volunteering?,
          volunteering_hours: @screener.volunteering_hours.to_s,
          volunteering_org_name: @screener.volunteering_org_name,
          work_hours: @screener.working_hours.to_s,
          work_training_name: @screener.work_training_name,
          working_or_earning: @screener.has_earnings_exemption?
        )
      end
      fields
    end

    def hash_for_generated_pdf
      shared_fields.merge(
        any_preventing_work: @screener.any_preventing_work?,
        earnings_above_minimum: @screener.earnings_above_minimum?,
        full_name: @screener.full_name,
        receiving_disability_benefits: @screener.receiving_disability_benefits?,
        working_30_or_more_hours: @screener.working_30_or_more_hours?
      )
    end

    def filled_pdf_tempfile
      source_pdf_path = filled_pdf_source
      template_doc = HexaPDF::Document.open(source_pdf_path)

      unless template_doc
        Rails.logger.error "Unable to generate PDF from #{source_pdf_path}"
        return
      end

      hash_for_fillable_pdf.each do |field_name, field_value|
        if field_value.is_a?(String)
          field_value = strip_emojis(field_value)
        end
        template_doc.acro_form.field_by_name(field_name.to_s).field_value = field_value
      end

      template_doc.acro_form.flatten

      pdf_tempfile = Tempfile.new(["packet", ".pdf"], "tmp/")
      template_doc.write(pdf_tempfile.path)
      pdf_tempfile.rewind
      pdf_tempfile
    end

    def generated_pdf_path
      html = PdfController.new.render_to_string(
        {
          template: generated_pdf_template,
          layout: "pdf",
          locals: strip_emojis_from_hash(hash_for_generated_pdf)
        }
      )
      css_path = Rails.root.join("app", "assets", "stylesheets", "wr_exemption_pdf.css")
      style_tag_options = [{path: css_path}]
      path = "tmp/page_1#{SecureRandom.uuid}.pdf"
      Grover.new(html, style_tag_options: style_tag_options, print_background: true).to_pdf(path)
      path
    end

    def combined_pdf
      generated_path = generated_pdf_path
      filled_pdf = filled_pdf_tempfile
      target = HexaPDF::Document.new

      [generated_path, filled_pdf_path].each do |file|
        pdf = HexaPDF::Document.open(file)
        pdf.pages.each { |page| target.pages << target.import(page) }
      end

      target.write_to_string
    ensure
      File.delete(generated_path) if generated_path && File.exist?(generated_path)
      filled_pdf&.close!
    end

    # Sanitizes text by removing emoji sequences:
    # - \p{Emoji_Presentation}: removes standalone emoji glyphs
    # - \p{Emoji}\uFE0F: removes emojis followed by variation selector-16
    # - \u200D: removes zero-width joiners used to combine emojis (e.g., family emojis)
    # Then normalizes whitespace via squeeze(" ") and strip.
    def strip_emojis(text)
      text
        .gsub(/\p{Emoji_Presentation}/, "")
        .gsub(/\p{Emoji}\uFE0F/, "")
        .delete("\u200D")
        .squeeze(" ")
        .strip
    end

    def strip_emojis_from_hash(hash)
      hash.transform_values do |value|
        value.is_a?(String) ? strip_emojis(value) : value
      end
    end

    private

    def shared_fields
      fields = {
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
        seasonal_worker: @screener.is_migrant_farmworker_yes?
      }
      if @screener.has_earnings_exemption?
        fields.merge!(
          volunteering_hours: @screener.volunteering_hours,
          work_hours: @screener.working_hours,
          work_training_hours: @screener.work_training_hours
        )
      end
      fields
    end

    def submission_date
      Date.current.to_s
    end
  end
end

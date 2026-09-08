module PdfFiller
  class PacketPdf
    PDF_PAGE_MARGIN = {top: "0.75in", bottom: "0.75in", left: "0.75in", right: "0.75in"}.freeze

    def initialize(screener)
      @screener = screener
    end

    def pdf_fields
      fields = {
        birth_date: @screener.birth_date.strftime("%B %-d, %Y"),
        caring_for_child_under_6: @screener.caring_for_child_under_6_yes?,
        caring_for_disabled_or_ill_person: @screener.caring_for_disabled_or_ill_person_yes?,
        enrolled_in_education: @screener.is_student_yes?,
        has_child: @screener.has_child_yes?,
        has_unemployment_benefits: @screener.has_unemployment_benefits_yes?,
        in_drug_or_alcohol_program: @screener.is_in_alcohol_treatment_program_yes?,
        is_american_indian: @screener.is_american_indian_yes?,
        is_pregnant: @screener.is_pregnant_yes?,
        pregnancy_due_date: @screener.pregnancy_due_date&.strftime("%B %-d, %Y").to_s,
        preventing_work_medical_condition: @screener.preventing_work_medical_condition_yes?,
        preventing_work_other: @screener.preventing_work_other_yes?,
        seasonal_worker: @screener.is_migrant_farmworker_yes?,
        age: @screener.age.to_s,
        any_preventing_work: @screener.any_preventing_work?,
        case_number: @screener.case_number,
        confirmation_code: @screener.confirmation_code,
        details_of_care: @screener.additional_care_info,
        drug_alcohol_program_name: @screener.alcohol_treatment_program_name,
        earnings_above_minimum: @screener.earnings_above_minimum?,
        email: @screener.email,
        full_name_with_middle: @screener.full_name_with_middle,
        phone_number: @screener.phone_number,
        preventing_work_write_in: @screener.preventing_work_additional_info,
        preventing_work_other_write_in: @screener.preventing_work_other_yes? && @screener.preventing_work_write_in,
        receiving_benefits_disability_medicaid: @screener.receiving_benefits_disability_medicaid_yes?,
        receiving_benefits_disability_pension: @screener.receiving_benefits_disability_pension_yes?,
        receiving_benefits_insurance_payments: @screener.receiving_benefits_insurance_payments_yes?,
        receiving_benefits_other: @screener.receiving_benefits_other_yes?,
        receiving_benefits_ssdi: @screener.receiving_benefits_ssdi_yes?,
        receiving_benefits_ssi: @screener.receiving_benefits_ssi_yes?,
        receiving_benefits_veterans_disability: @screener.receiving_benefits_veterans_disability_yes?,
        receiving_benefits_workers_compensation: @screener.receiving_benefits_workers_compensation_yes?,
        receiving_benefits_write_in: @screener.receiving_benefits_other_yes? && @screener.receiving_benefits_write_in,
        receiving_disability_benefits: @screener.receiving_disability_benefits?,
        signature: @screener.signature,
        ssn_last_4: @screener.ssn_last_four,
        submission_date: submission_date,
        working_30_or_more_hours: @screener.working_30_or_more_hours?,
        state: @screener.state,
        # Defaults for the fields that don't apply to every screener: the income fields
        # below are only filled in for a screener with an earnings exemption, and the
        # North Carolina ones only by NcPacketPdf. They are declared here, rather than
        # left out of the hash, because pdf/packet.html.erb reads all of them -- a
        # reference to a local that was never passed to a template raises NameError, so
        # leaving one out means the template has to declare a default for it instead.
        earnings_per_week: nil,
        is_in_work_training: false,
        is_volunteering: false,
        volunteering_hours: nil,
        volunteering_org_name: nil,
        work_hours: nil,
        work_training_name: nil,
        work_training_hours: nil,
        working_or_earning: false,
        homeschool_hours: nil,
        homeschool_name: nil,
        operating_a_homeschool: false,
        operating_homeschool_30_or_more_hours: false,
        at_least_55_no_diploma_not_working: false,
        preventing_work_place_to_sleep: false,
        preventing_work_domestic_violence: false,
        preventing_work_drugs_alcohol: false
      }

      if @screener.has_earnings_exemption?
        fields.merge!(
          earnings_per_week: @screener.working_weekly_earnings.to_s,
          is_in_work_training: @screener.is_in_work_training_yes?,
          is_volunteering: @screener.volunteering?,
          volunteering_hours: @screener.volunteering_hours.to_s,
          volunteering_org_name: @screener.volunteering_org_name,
          work_hours: @screener.working_hours.to_s,
          work_training_hours: @screener.work_training_hours,
          work_training_name: @screener.work_training_name,
          working_or_earning: true
        )
      end

      fields
    end

    def to_pdf
      html = PdfController.new.render_to_string(
        {
          template: "pdf/packet",
          layout: "pdf",
          locals: strip_emojis_from_hash(pdf_fields)
        }
      )
      style_tag_options = [
        {path: Rails.root.join("app", "assets", "builds", "application.css")},
        {path: Rails.root.join("app", "assets", "stylesheets", "wr_exemption_pdf.css")}
      ]
      Grover.new(
        html,
        style_tag_options: style_tag_options,
        print_background: true,
        timeout: 120_000,
        margin: PDF_PAGE_MARGIN
      ).to_pdf
    end

    # Sanitizes text by removing emoji sequences:
    # - \p{Emoji_Presentation}: removes standalone emoji glyphs
    # - \p{Emoji}\uFE0F: removes emojis followed by variation selector-16
    # - \u200D, \uFE0F, \u20E3: removes zero-width joiners, variation selectors, and keycap
    #   combiners left on their own once the emoji they modified is already gone (e.g. a mobile
    #   keyboard's emoji autosuggest leaving one behind, as in "1\uFE0F\u20E3" losing its "1").
    #   Then normalizes whitespace via squeeze(" ") and strip.
    def strip_emojis(text)
      text
        .gsub(/\p{Emoji_Presentation}/, "")
        .gsub(/\p{Emoji}\uFE0F/, "")
        .delete("\u200D\uFE0F\u20E3")
        .squeeze(" ")
        .strip
    end

    def strip_emojis_from_hash(hash)
      hash.transform_values do |value|
        value.is_a?(String) ? strip_emojis(value) : value
      end
    end

    private

    def submission_date
      Date.current.strftime("%B %-d, %Y")
    end
  end
end

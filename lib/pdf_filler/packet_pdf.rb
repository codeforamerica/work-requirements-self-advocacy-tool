module PdfFiller
  class PacketPdf
    UNSUPPORTED_GLYPH_MESSAGE_PATTERN = /no codepoint for :(\w+)/
    UNSUPPORTED_CHARACTER_REPLACEMENT = "_"
    PDF_PAGE_MARGIN = {top: "0.75in", bottom: "0.75in", left: "0.75in", right: "0.75in"}.freeze

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
        age: @screener.age.to_s,
        any_preventing_work: @screener.any_preventing_work?,
        case_number: @screener.case_number,
        earnings_above_minimum: @screener.earnings_above_minimum?,
        email: @screener.email,
        full_name: @screener.full_name,
        full_name_with_middle: @screener.full_name_with_middle,
        phone_number: @screener.phone_number,
        receiving_disability_benefits: @screener.receiving_disability_benefits?,
        ssn_last_4: @screener.ssn_last_four,
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

        field = template_doc.acro_form.field_by_name(field_name.to_s)

        assign_field_value(field, field_name, field_value)
      end

      template_doc.acro_form.flatten

      pdf_tempfile = Tempfile.new(["packet", ".pdf"], "tmp/")
      template_doc.write(pdf_tempfile.path)
      pdf_tempfile
    end

    def generated_pdf_path
      html = PdfController.renderer.render(
        template: generated_pdf_template,
        layout: "pdf",
        locals: strip_emojis_from_hash(hash_for_generated_pdf)
      )
      css_path = Rails.root.join("app", "assets", "stylesheets", "wr_exemption_pdf.css")
      style_tag_options = [{path: css_path}]
      path = "tmp/page_1#{SecureRandom.uuid}.pdf"
      Grover.new(html, style_tag_options: style_tag_options, print_background: true, timeout: 120_000).to_pdf(path)
      path
    end

    def combined_pdf
      target = HexaPDF::Document.new
      generated_path = generated_pdf_path
      filled_pdf = filled_pdf_tempfile

      [generated_path, filled_pdf].each do |file|
        pdf = HexaPDF::Document.open(file)
        pdf.pages.each { |page| target.pages << target.import(page) }
      end

      target.write_to_string
    ensure
      File.delete(generated_path) if generated_path && File.exist?(generated_path)
      filled_pdf&.close!
    end

    def combined_pdf_all_html
      html = PdfController.new.render_to_string(
        {
          template: "pdf/combined_packet",
          layout: "pdf",
          locals: {
            generated_locals: strip_emojis_from_hash(hash_for_generated_pdf),
            # state isn't an AcroForm field, so it's merged in here rather than into
            # hash_for_fillable_pdf, which filled_pdf_tempfile also uses to fill the
            # real PDF form fields by name -- an unknown field name there raises.
            fillable_locals: strip_emojis_from_hash(hash_for_fillable_pdf).merge(state: @screener.state)
          }
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
    #   These have no glyph of their own in any font, so left alone they'd hit the
    #   MissingGlyphError fallback.
    # Then normalizes whitespace via squeeze(" ") and strip.
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

    # Assigns a field value, and if the PDF's font can't encode a character in it (e.g. "ń", which
    # isn't in the template's Helvetica /Differences table), replaces that character with its
    # closest unaccented Latin equivalent (falling back to UNSUPPORTED_CHARACTER_REPLACEMENT if it
    # has none) and retries. LatinScriptValidator should already keep non-Latin-script text (e.g.
    # Arabic, Cyrillic) out of these fields entirely -- if one somehow gets through, this raises
    # instead of silently mangling it, since there's no meaningful "closest Latin equivalent" for a
    # different script. Any other HexaPDF error (e.g. /MaxLen exceeded) is logged with diagnostic
    # context and re-raised.
    #
    # Each retry replaces every occurrence of one distinct unsupported character (via String#gsub),
    # so the recursion can never run more times than there are distinct characters in the value --
    # always <= its length. replacements_remaining defaults to that length as a hard, self-scaling
    # ceiling against runaway recursion, rather than an arbitrary constant.
    def assign_field_value(field, field_name, value, replacements_remaining: value.to_s.length)
      field.field_value = value
    rescue HexaPDF::MissingGlyphError => e
      # e.glyph.str is the actual character that has no glyph in the font at all (e.g. a stray
      # variation selector left behind by a mobile keyboard's emoji autosuggest). e.glyph.name is
      # unusable here -- for these it's always the font's generic ".notdef" placeholder, not a
      # real Adobe Glyph List name, so it can't be mapped back to a character.
      replace_unsupported_character_and_retry(field, field_name, value, e.glyph.str, replacements_remaining)
    rescue HexaPDF::Error => e
      # A different failure mode: the glyph itself is known (has a real AGL name, e.g. :nacute for
      # "ń"), but the font's fixed encoding table has no free slot left to map it to. Recover the
      # character from its glyph name here instead, since there's no glyph object on this error.
      match = e.message.match(UNSUPPORTED_GLYPH_MESSAGE_PATTERN)
      unless match
        Rails.logger.error("PDF field assignment failed: field=#{field_name} max_len=#{field[:MaxLen].inspect} length=#{value.to_s.length} screener=#{@screener.id}")
        raise
      end

      character = HexaPDF::Font::Encoding::GlyphList.name_to_unicode(match[1].to_sym)
      unless character
        raise HexaPDF::Error, "Unsupported glyph #{match[1].inspect} could not be mapped to a character"
      end

      replace_unsupported_character_and_retry(field, field_name, value, character, replacements_remaining)
    end

    def replace_unsupported_character_and_retry(field, field_name, value, character, replacements_remaining)
      if replacements_remaining <= 0
        raise HexaPDF::Error, "Too many unsupported characters in field #{field_name}"
      end

      unless character.match?(LatinScriptValidator::PATTERN)
        raise HexaPDF::Error, "Non-Latin-script character in field #{field_name} could not be rendered"
      end

      replacement = ActiveSupport::Inflector.transliterate(character)
      replacement = UNSUPPORTED_CHARACTER_REPLACEMENT if replacement == character

      Rails.logger.warn("PDF field assignment: replaced unsupported character field=#{field_name} character=#{character.inspect} replacement=#{replacement.inspect} screener=#{@screener.id}")

      assign_field_value(field, field_name, value.gsub(character, replacement),
        replacements_remaining: replacements_remaining - 1)
    end

    def shared_fields
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
      Date.current.strftime("%B %-d, %Y")
    end
  end
end

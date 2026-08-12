module PdfHelper
  # SPIKE (WRSAT-687): inlines section-icon/checkbox SVGs from app/assets/images
  # (see ApplicationHelper#inline_svg) rather than an <img>/font glyph, since
  # Grover's headless-browser rendering can't resolve the relative font URLs
  # Honeycrisp's Material Icons font uses (same reason generated_pdf_path's
  # logo image uses an absolute URL instead of the asset pipeline path).
  def person_icon
    inline_svg("pdf-person.svg")
  end

  def document_icon
    inline_svg("pdf-document.svg")
  end

  def work_icon
    inline_svg("pdf-work.svg")
  end

  def signature_icon
    inline_svg("pdf-signature.svg")
  end

  def checkbox_icon
    inline_svg("pdf-checkbox-checked.svg")
  end

  # SPIKE (WRSAT-687): only renders when checked -- unlike a real PDF checkbox
  # field, an absent HTML item can't show an empty box, so unchecked items in
  # the Reported Exemptions / Fitness for Work sections are omitted entirely.
  def checklist_item(label, checked)
    return unless checked

    content_tag(:li, class: "checklist-item") do
      checkbox_icon + content_tag(:span, label)
    end
  end

  def info_field(label, value)
    content_tag(:div, class: "info-field") do
      content_tag(:span, label, class: "info-label") + content_tag(:span, value)
    end
  end
end

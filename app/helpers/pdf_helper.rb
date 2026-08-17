module PdfHelper
  def checkbox_icon
    inline_svg("pdf-checkbox-checked.svg")
  end

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

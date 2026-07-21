module PdfHelper
  # SPIKE (WRSAT-687): small inline SVGs so section icons/checkboxes render
  # under Grover, which can't resolve the relative font URLs Honeycrisp's
  # Material Icons font uses (same reason generated_pdf_path's logo image
  # uses an absolute URL instead of the asset pipeline path).
  def svg_icon(path_d)
    content_tag(:svg, width: 20, height: 20, viewBox: "0 0 24 24", fill: "#034e46") do
      tag(:path, d: path_d)
    end
  end

  def person_icon
    svg_icon("M12 12c2.7 0 4.9-2.2 4.9-4.9S14.7 2.2 12 2.2 7.1 4.4 7.1 7.1 9.3 12 12 12zm0 2.5c-3.3 0-9.8 1.6-9.8 4.9v2.4h19.6v-2.4c0-3.3-6.5-4.9-9.8-4.9z")
  end

  def document_icon
    svg_icon("M6 2c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6H6zm7 7V3.5L18.5 9H13z")
  end

  def benefits_icon
    svg_icon("M12 21s-7.5-4.6-10-9.3C.5 8.5 2 5 5.5 5c2 0 3.3 1.1 4 2.1.7-1 2-2.1 4-2.1 3.5 0 5 3.5 3.5 6.7C19.5 16.4 12 21 12 21z")
  end

  def work_icon
    svg_icon("M10 4h4a2 2 0 0 1 2 2v1h3a2 2 0 0 1 2 2v3H3V9a2 2 0 0 1 2-2h3V6a2 2 0 0 1 2-2zm0 3h4V6h-4v1zM3 13h18v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-5z")
  end

  def list_icon
    svg_icon("M4 6h2v2H4zM8 6h12v2H8zM4 11h2v2H4zM8 11h12v2H8zM4 16h2v2H4zM8 16h12v2H8z")
  end

  def signature_icon
    svg_icon("M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z")
  end

  def checkbox_icon(checked)
    content_tag(:svg, width: 18, height: 18, viewBox: "0 0 24 24", fill: "none") do
      if checked
        tag(:rect, x: 2, y: 2, width: 20, height: 20, rx: 3, fill: "#034e46") +
          tag(:path, d: "M7 12.5l3 3 7-7", stroke: "white", "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", fill: "none")
      else
        tag(:rect, x: 2, y: 2, width: 20, height: 20, rx: 3, fill: "white", stroke: "#121111", "stroke-width": 2)
      end
    end
  end

  def checklist_item(label, checked)
    content_tag(:li, class: "checklist-item") do
      checkbox_icon(checked) + content_tag(:span, label)
    end
  end

  def info_field(label, value)
    content_tag(:div, class: "info-field") do
      content_tag(:span, label, class: "info-label") + content_tag(:span, value)
    end
  end
end

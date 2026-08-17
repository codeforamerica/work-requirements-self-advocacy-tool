class PdfController < QuestionController
  layout "pdf"

  def generate_pdf
    send_mixpanel_event(event_name: "pdf_downloaded")
    send_data current_screener.pdf, filename: "combined.pdf", disposition: "inline"
  end
end

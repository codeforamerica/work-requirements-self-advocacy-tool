class PdfController < QuestionController
  layout "pdf"
  skip_before_action :set_screener_current_step_and_locale

  def generate_pdf
    send_mixpanel_event(event_name: "pdf_downloaded")
    send_data current_screener.pdf, filename: "combined.pdf", disposition: "inline"
  end
end

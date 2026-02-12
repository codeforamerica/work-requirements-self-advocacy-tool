class TempEndController < QuestionController
  layout "application"
  def show_progress_bar
    false
  end

  def generate_pdf
    screener = Screener.create(
      first_name: "Testy",
      middle_name: "Mary",
      last_name: "Testerson",
      birth_date: Date.new(1976, 3, 6),
      email: "testy@example.com",
      is_american_indian: "yes"
    )
    send_data PdfFiller::PacketPdf.new(screener).combined_pdf, filename: "combined.pdf", disposition: "inline"
  end
end

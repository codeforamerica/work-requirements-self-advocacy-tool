class PacketPageOneController < QuestionController
  layout "pdf"
  before_action :build_temp_screener

  # TODO: eventually this will use a real screener but for ease of development as we fill out the whole PDF, use this
  def build_temp_screener
    @temp_screener ||= Screener.new(
      first_name: "Testy",
      middle_name: "Mary",
      last_name: "Testerson",
      birth_date: Date.new(1976, 3, 6),
      email: "testy@example.com",
      caring_for_child_under_6: "yes"
    )
  end

  def generate_pdf
    send_data PdfFiller::PacketPdf.new(@temp_screener).combined_pdf, filename: "combined.pdf", disposition: "inline"
  end

  def page
    render :page, locals: PdfFiller::PacketPdf.new(@temp_screener).hash_for_pdf
  end
end

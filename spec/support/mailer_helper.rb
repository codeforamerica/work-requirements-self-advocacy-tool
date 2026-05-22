module MailHelper
  def html_doc(mail)
    Nokogiri::HTML(mail.html_part.body.to_s)
  end

  def html_body(mail)
    mail.html_part.body.to_s
  end

  def text_body(mail)
    mail.text_part.body.to_s
  end
end

RSpec.configure do |config|
  config.include MailHelper
end

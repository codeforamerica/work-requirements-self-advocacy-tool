class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from_address }
  layout "mailer"

  protected

  def attach_header_image
    attachments.inline["gbh_email_header.png"] = File.binread(Rails.root.join("app/assets/images/gbh_email_header.png"))
  end

  def apply_ses_headers
    if ENV["SES_CONFIGURATION_SET"]
      headers["X-SES-CONFIGURATION-SET"] = ENV["SES_CONFIGURATION_SET"]
    end

    if ENV["SES_CONTACT_LIST"]
      headers["X-SES-LIST-MANAGEMENT-OPTIONS"] = "#{ENV["SES_CONTACT_LIST"]}; topic=general"
    end
  end

  def default_from_address
    "noreply@#{ENV.fetch("EMAIL_DOMAIN", "codeforamerica.app")}"
  end
end

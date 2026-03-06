class ScreenerMailer < ApplicationMailer
  default from: "noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")

  def download_pdf(outgoing_email:)
    screener = outgoing_email.screener
    mail(to: screener.email, subject: "[GetBenefitsHelp] Your SNAP Work Rules form")
  end
end

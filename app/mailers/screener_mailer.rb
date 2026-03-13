class ScreenerMailer < ApplicationMailer
  default from: "noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")

  def send_screener_results(outgoing_email:)
    @screener = outgoing_email.screener
    @county_data = LocationData::Counties.get(@screener.state, @screener.county)
    attachments.inline["gbh_email_header.png"] = File.binread(Rails.root.join("app/assets/images/gbh_email_header.png"))
    mail(to: @screener.email, subject: "[GetBenefitsHelp] Your SNAP Work Rules form")
  end
end

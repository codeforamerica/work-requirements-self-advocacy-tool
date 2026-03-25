class ScreenerMailerPreview < ActionMailer::Preview
  def send_screener_results
    screener = FactoryBot.build(
      :screener,
      email: "preview@example.com",
      first_name: "Dog",
      last_name: "Ham",
      state: "NC",
      county: "Burke County",
      confirmation_code: "123ABC"
    )
    outgoing_email = FactoryBot.build(:outgoing_email, screener: screener)
    ScreenerMailer.send_screener_results(outgoing_email: outgoing_email)
  end
end

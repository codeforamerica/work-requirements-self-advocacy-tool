class ScreenerMailerPreview < ActionMailer::Preview
  def send_screener_results
    screener = FactoryBot.build(
      :screener,
      email: "preview@example.com",
      first_name: "Dog",
      last_name: "Ham",
      state: "NC",
      county: "Burke County",
      confirmation_code: "123ABC",
      is_student: "yes",
      preventing_work_drugs_alcohol: "yes",
      receiving_benefits_ssdi: "yes",
      receiving_benefits_ssi: "yes",
      receiving_benefits_veterans_disability: "yes",
      receiving_benefits_other: "yes",
      is_in_alcohol_treatment_program: "yes"
    )
    outgoing_email = FactoryBot.build(:outgoing_email, screener: screener)
    ScreenerMailer.send_screener_results(outgoing_email: outgoing_email)
  end
end

class ScreenerMailerPreview < ActionMailer::Preview
  def send_screener_results_nc
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
      is_in_alcohol_treatment_program: "yes",
      nc_screener: FactoryBot.build(:nc_screener)
    )
    outgoing_email = FactoryBot.build(:outgoing_email, screener: screener)
    ScreenerMailer.send_screener_results(outgoing_email: outgoing_email)
  end

  def send_screener_results_de
    screener = FactoryBot.build(
      :screener,
      email: "preview@example.com",
      first_name: "Cat",
      last_name: "Spam",
      state: "DE",
      zip_code: "19735",
      confirmation_code: "2345DEF",
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

  def send_screener_results_de_special_geo
    screener = FactoryBot.build(
      :screener,
      email: "preview@example.com",
      first_name: "Kat",
      last_name: "Spam",
      state: "DE",
      zip_code: "19720",
      confirmation_code: "2345DEF",
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

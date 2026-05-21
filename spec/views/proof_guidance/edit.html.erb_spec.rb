require "rails_helper"

RSpec.describe "proof_guidance/edit", type: :view do
  let(:screener) { create(:screener) }

  before do
    assign(:current_screener, screener)
    without_partial_double_verification do
      allow(view).to receive(:next_path).and_return("/next")
    end
  end

  it "always displays the title and next steps" do
    render
    expect(rendered).to include(I18n.t("views.proof_guidance.edit.title"))
    I18n.t("views.proof_guidance.edit.next_steps_html").each do |step|
      expect(rendered).to include(step)
    end
  end

  describe "proof of working section" do
    it "shows section when requires_proof? is true" do
      allow(screener).to receive(:requires_proof?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_you_may_need"))
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.already_has_proof"))
    end

    it "hides section when requires_proof? is false" do
      allow(screener).to receive(:requires_proof?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_you_may_need"))
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.already_has_proof"))
    end

    it "shows when earnings are above minimum and not exempt from work rules" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(true)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_working_html"))
    end

    it "does not show when earnings are below minimum" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(false)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_working_html"))
    end

    it "does not show when exempt from work rules" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(true)
      allow(screener).to receive(:exempt_from_work_rules?).and_return(true)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_working_html"))
    end
  end

  describe "proof of education section" do
    it "shows when is a student" do
      screener.update(is_student: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_education_html"))
    end

    it "does not show when is not a student" do
      screener.update(is_student: "no")
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_education_html"))
    end

    it "shows over-50 additional guidance when student is over 50" do
      screener.update(is_student: "yes", birth_date: 51.years.ago.to_date)
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_education_over_50_html"))
    end

    it "does not show over-50 guidance when student is 50 or younger" do
      screener.update(is_student: "yes", birth_date: 50.years.ago.to_date)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_education_over_50_html"))
    end

    it "does not throw error when age is nil" do
      screener.update(is_student: "yes", birth_date: nil)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_education_over_50_html"))
    end
  end

  describe "proof of health and/or substance use condition section" do
    it "only shows substance use when preventing work due to drugs/alcohol" do
      screener.update(preventing_work_drugs_alcohol: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title")))
    end

    it "only shows medical condition when preventing work due to medical condition" do
      screener.update(preventing_work_medical_condition: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_condition_only_title")))
    end

    it "shows both medical condition and substance use when preventing work due to medical condition and preventing work due to drugs/alcohol" do
      screener.update(preventing_work_medical_condition: "yes", preventing_work_drugs_alcohol: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title")))
    end

    it "only shows substance use when preventing work due to drugs/alcohol -- DE version" do
      screener.update(preventing_work_drugs_alcohol: "yes", state: "DE")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_de"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title")))
    end

    it "only shows medical condition when preventing work due to medical condition -- DE version" do
      screener.update(preventing_work_medical_condition: "yes", state: "DE")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_de"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_condition_only_title")))
    end

    it "shows both medical condition and substance use when preventing work due to medical condition and preventing work due to drugs/alcohol -- DE version" do
      screener.update(preventing_work_medical_condition: "yes", preventing_work_drugs_alcohol: "yes", state: "DE")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_de"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title")))
    end

    it "does not show when no health-related preventing work conditions" do
      screener.update(preventing_work_drugs_alcohol: "no", preventing_work_medical_condition: "no")
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: ""))
    end
  end

  describe "proof of disability benefits section" do
    it "shows when receiving any disability benefit" do
      screener.update(receiving_benefits_ssdi: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
    end

    it "lists only the specific benefits the screener receives" do
      screener.update(receiving_benefits_ssdi: "yes", receiving_benefits_veterans_disability: "yes")
      render
      unescaped = CGI.unescape_html(rendered)
      expect(unescaped).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssdi"))
      expect(unescaped).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_veterans_disability"))
      expect(unescaped).not_to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssi"))
      expect(unescaped).not_to include(I18n.t("views.disability_benefits.edit.receiving_benefits_workers_compensation"))
    end

    it "does not show when not receiving any disability benefits" do
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
    end
  end

  describe "proof of treatment program section" do
    it "shows when in an alcohol treatment program" do
      screener.update(is_in_alcohol_treatment_program: "yes")
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
    end

    it "does not show when not in an alcohol treatment program" do
      screener.update(is_in_alcohol_treatment_program: "no")
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
    end
  end

  describe "proof of native american section" do
    it "shows when american indian exemption is true" do
      screener.update(is_american_indian: "yes")
      allow(screener).to receive(:american_indian_exemption_requires_proof?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.proof_guidance.edit.proof_of_native_american_html"))
    end

    it "does not show when american indian exemeption is false" do
      screener.update(is_american_indian: "no")
      allow(screener).to receive(:american_indian_exemption_requires_proof?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.proof_guidance.edit.proof_of_native_american_html"))
    end
  end
end

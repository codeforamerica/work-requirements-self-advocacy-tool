require "rails_helper"

RSpec.describe "signature/edit", type: :view do
  let(:screener) { create(:screener) }

  before do
    assign(:current_screener, screener)
    assign(:model, screener)
  end

  it "displays the title, privacy policy, perjury statement, and signature form" do
    render
    unescaped = CGI.unescape_html(rendered)
    expect(unescaped).to include(I18n.t("views.signature.edit.title"))
    expect(rendered).to include("Privacy Policy")
    expect(rendered).to include(I18n.t("views.signature.edit.perjury_statement"))
    expect(rendered).to include(I18n.t("views.signature.edit.signature_label"))
    expect(rendered).to include(I18n.t("views.signature.edit.signature_help_text"))
  end

  describe "exemption: American Indian" do
    it "shows when selected" do
      screener.update(is_american_indian: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_american_indian"))
    end

    it "does not show when not selected" do
      screener.update(is_american_indian: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_american_indian"))
    end
  end

  describe "exemption: living with child under 14" do
    it "shows when selected" do
      screener.update(has_child: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_child_under_14"))
    end

    it "does not show when not selected" do
      screener.update(has_child: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_child_under_14"))
    end
  end

  describe "exemption: caring for child under 6" do
    it "shows when selected" do
      screener.update(caring_for_child_under_6: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_caring_child_under_6"))
    end

    it "does not show when not selected" do
      screener.update(caring_for_child_under_6: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_caring_child_under_6"))
    end
  end

  describe "exemption: caring for incapacitated person" do
    it "shows when selected" do
      screener.update(caring_for_disabled_or_ill_person: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_caring_incapacitated"))
    end

    it "does not show when not selected" do
      screener.update(caring_for_disabled_or_ill_person: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_caring_incapacitated"))
    end
  end

  describe "exemption: pregnant" do
    it "shows with due date when pregnant and due date is present" do
      screener.update(is_pregnant: "yes", pregnancy_due_date: Date.new(2026, 8, 15))
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_pregnant", date: "08/15/2026"))
    end

    it "shows without due date when pregnant and due date is not present" do
      screener.update(is_pregnant: "yes", pregnancy_due_date: nil)
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_pregnant_no_date"))
    end

    it "does not show when not pregnant" do
      screener.update(is_pregnant: "no")
      render
      expect(rendered).not_to include("Pregnant")
    end
  end

  describe "exemption: unemployment benefits" do
    it "shows when selected" do
      screener.update(has_unemployment_benefits: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_unemployment"))
    end

    it "does not show when not selected" do
      screener.update(has_unemployment_benefits: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_unemployment"))
    end
  end

  describe "exemption: disability benefits" do
    it "shows when receiving any disability benefit" do
      screener.update(receiving_benefits_ssdi: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_disability_benefits"))
    end

    it "does not show when not receiving disability benefits" do
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_disability_benefits"))
    end
  end

  describe "exemption: working 30+ hours" do
    it "shows when working 30 or more hours" do
      screener.update(is_working: "yes", working_hours: 30)
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_working_30_hours"))
    end

    it "does not show when working fewer than 30 hours" do
      screener.update(is_working: "yes", working_hours: 20)
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_working_30_hours"))
    end

    it "does not show when not working" do
      screener.update(is_working: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_working_30_hours"))
    end
  end

  describe "exemption: earnings above minimum" do
    it "shows when earning at least $217.50 per week" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_earnings"))
    end

    it "does not show when earning below minimum" do
      allow(screener).to receive(:earnings_above_minimum?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_earnings"))
    end
  end

  describe "exemption: migrant farmworker" do
    it "shows when selected" do
      screener.update(is_migrant_farmworker: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_migrant_farmworker"))
    end

    it "does not show when not selected" do
      screener.update(is_migrant_farmworker: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_migrant_farmworker"))
    end
  end

  describe "exemption: student" do
    it "shows when selected" do
      screener.update(is_student: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_student"))
    end

    it "does not show when not selected" do
      screener.update(is_student: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_student"))
    end
  end

  describe "exemption: alcohol treatment program" do
    it "shows when selected" do
      screener.update(is_in_alcohol_treatment_program: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_alcohol_treatment"))
    end

    it "does not show when not selected" do
      screener.update(is_in_alcohol_treatment_program: "no")
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_alcohol_treatment"))
    end
  end

  describe "exemption: NC age/education/health (55+)" do
    let(:screener) { create(:screener, :with_nc_screener) }

    it "shows when NC screener qualifies" do
      allow(screener.nc_screener).to receive(:age_work_education_health_exemption?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_55_no_diploma"))
    end

    it "does not show when NC screener does not qualify" do
      allow(screener.nc_screener).to receive(:age_work_education_health_exemption?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_55_no_diploma"))
    end
  end

  describe "exemption: NC homeschool 30+ hours" do
    let(:screener) { create(:screener, :with_nc_screener) }

    it "shows when teaching homeschool 30+ hours" do
      allow(screener.nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.signature.edit.exemption_homeschool"))
    end

    it "does not show when not teaching homeschool" do
      allow(screener.nc_screener).to receive(:operating_homeschool_30_or_more_hours?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.exemption_homeschool"))
    end
  end

  describe "preventing work situations" do
    it "does not show the section when no preventing work situations" do
      render
      expect(rendered).not_to include(I18n.t("views.signature.edit.preventing_work_place_to_sleep"))
    end

    it "shows singular heading with one situation" do
      screener.update(preventing_work_place_to_sleep: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_heading", count: 1))
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_place_to_sleep"))
    end

    it "shows plural heading with multiple situations" do
      screener.update(preventing_work_place_to_sleep: "yes", preventing_work_domestic_violence: "yes")
      render
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_heading", count: 2))
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_place_to_sleep"))
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_domestic_violence"))
    end

    it "shows each preventing work situation only when selected" do
      screener.update(
        preventing_work_place_to_sleep: "yes",
        preventing_work_domestic_violence: "no",
        preventing_work_drugs_alcohol: "yes",
        preventing_work_medical_condition: "no",
        preventing_work_other: "no"
      )
      render
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_place_to_sleep"))
      expect(rendered).not_to include(I18n.t("views.signature.edit.preventing_work_domestic_violence"))
      expect(rendered).to include(I18n.t("views.signature.edit.preventing_work_drugs_alcohol"))
      expect(rendered).not_to include(I18n.t("views.signature.edit.preventing_work_medical_condition"))
    end

    it "shows 'Other' with write-in text when present" do
      screener.update(preventing_work_other: "yes", preventing_work_write_in: "caring for elderly parent")
      render
      expect(rendered).to include("Other")
      expect(rendered).to include("caring for elderly parent")
    end

    it "shows 'Other' without write-in text when write-in is not present" do
      screener.update(preventing_work_other: "yes", preventing_work_write_in: nil)
      render
      expect(rendered).to include("Other")
    end
  end
end

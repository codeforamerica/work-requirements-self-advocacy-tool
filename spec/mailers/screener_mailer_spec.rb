require "rails_helper"

RSpec.describe ScreenerMailer, type: :mailer do
  describe "send_screener_results" do
    let(:screener) { create(:screener) }
    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }
    let(:body) { mail.html_part.body.to_s }

    it "renders the headers and body" do
      expect(mail.subject).to eq(I18n.t("views.screener_mailer.send_screener_results.subject"))
      expect(mail.from).to eq(["noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")])
      expect(body).to include(I18n.t("views.screener_mailer.send_screener_results.next_step_heading"))
    end

    context "proof section" do
      context "when is_student is yes" do
        let(:screener) { create(:screener, is_student: "yes") }

        it "includes proof of education" do
          expect(body).to include(I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_html"))
        end
      end

      context "when is_student is not yes" do
        it "does not include proof of education" do
          expect(body).not_to include(I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_html"))
        end
      end

      context "when preventing_work_drugs_alcohol is yes" do
        let(:screener) { create(:screener, preventing_work_drugs_alcohol: "yes") }

        it "includes proof of health conditions" do
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html"))
        end
      end

      context "when preventing_work_medical_condition is yes" do
        let(:screener) { create(:screener, preventing_work_medical_condition: "yes") }

        it "includes proof of health conditions" do
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html"))
        end
      end

      context "when neither drugs nor medical condition is yes" do
        it "does not include proof of health conditions" do
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html"))
        end
      end

      context "when receiving disability benefits" do
        let(:screener) { create(:screener, receiving_benefits_ssdi: "yes", receiving_benefits_ssi: "yes") }

        it "includes proof of disability benefits with selected benefits" do
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
          expect(body).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssdi"))
          expect(body).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssi"))
        end

        it "does not include unselected benefits" do
          expect(body).not_to include(I18n.t("views.disability_benefits.edit.receiving_benefits_veterans_disability"))
        end
      end

      context "when receiving other disability benefits with write-in" do
        let(:screener) { create(:screener, receiving_benefits_other: "yes", receiving_benefits_write_in: "Many bennies") }

        it "includes the write-in text" do
          expect(body).to include("Many bennies")
        end
      end

      context "when not receiving any disability benefits" do
        it "does not include proof of disability benefits" do
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
        end
      end

      context "when is_in_alcohol_treatment_program is yes" do
        let(:screener) { create(:screener, is_in_alcohol_treatment_program: "yes") }

        it "includes proof of treatment program" do
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
        end
      end

      context "when is_in_alcohol_treatment_program is not yes" do
        it "does not include proof of treatment program" do
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
        end
      end
    end
  end
end

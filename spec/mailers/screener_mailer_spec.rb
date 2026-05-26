require "rails_helper"

RSpec.describe ScreenerMailer, type: :mailer do
  describe "send_screener_results" do
    let(:screener) { create(:screener, :with_nc_screener, :with_exemption) }
    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }
    let(:body) { html_body(mail) }

    it_behaves_like "a mailer with default headers"

    it "renders the headers and body" do
      expect(mail.subject).to eq(I18n.t("views.screener_mailer.send_screener_results.subject"))
      expect(body).to include(I18n.t("views.screener_mailer.send_screener_results.next_step_heading"))
    end

    context "instructions section" do
      context "when state is NC" do
        it "includes NC ePASS instructions" do
          screener.update(state: "NC")
          expect(body).to include(I18n.t("views.screener_mailer.send_screener_results.online_submit_nc_html"))
          expect(html_doc(mail).text).to include(I18n.t("views.screener_mailer.send_screener_results.online_county",
            website_name: I18n.t("views.screener_mailer.send_screener_results.website_name_nc"),
            website: "https://dconc.gov/Social-Services/Food-and-Nutrition-Services"))
        end
      end
    end

    context "proof section" do
      context "when is_student is yes" do
        it "includes proof of education" do
          screener.update(is_student: "yes")
          expect(body).to include(I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_html"))
        end
      end

      context "when is_student is not yes" do
        it "does not include proof of education" do
          screener.update(is_student: "no")
          expect(body).not_to include(I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_html"))
        end
      end

      context "when preventing_work_drugs_alcohol is yes" do
        it "includes proof of health and substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "yes")
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title"), condition_type: I18n.t("views.proof_guidance.edit.condition_medical_health")))
        end
      end

      context "when preventing_work_drugs_alcohol is yes and preventing_work_medical_condition is no" do
        it "includes proof of only substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "yes", preventing_work_medical_condition: "no")
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title"), condition_type: I18n.t("views.proof_guidance.edit.condition_substance_use")))
        end
      end

      context "when preventing_work_medical_condition is yes" do
        it "includes proof of only health conditions" do
          screener.update(preventing_work_medical_condition: "yes")
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: I18n.t("views.proof_guidance.edit.proof_of_health_condition_only_title"), condition_type: I18n.t("views.proof_guidance.edit.condition_medical_health")))
        end
      end

      context "when neither drugs nor medical condition is yes" do
        it "does not include proof of health or substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "no", preventing_work_medical_condition: "no")
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: I18n.t("views.proof_guidance.edit.proof_of_health_form_nc"), proof_of_condition_title: "", condition_type: ""))
        end
      end

      context "when receiving disability benefits" do
        it "includes proof of disability benefits with selected benefits only" do
          screener.update(receiving_benefits_ssdi: "yes", receiving_benefits_ssi: "yes", receiving_benefits_other: "yes", receiving_benefits_write_in: "Many bennies")

          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
          expect(body).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssdi"))
          expect(body).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssi"))
          expect(body).to include("Many bennies")
          expect(body).not_to include(I18n.t("views.disability_benefits.edit.receiving_benefits_veterans_disability"))
        end
      end

      context "when not receiving any disability benefits" do
        it "does not include proof of disability benefits" do
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html"))
        end
      end

      context "when is_in_alcohol_treatment_program is yes" do
        it "includes proof of treatment program" do
          screener.update(is_in_alcohol_treatment_program: "yes")
          expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
        end
      end

      context "when is_in_alcohol_treatment_program is not yes" do
        it "does not include proof of treatment program" do
          screener.update(is_in_alcohol_treatment_program: "no")
          expect(body).not_to include(I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html"))
        end
      end
    end

    it "attaches the work requirements PDF" do
      pdf_attachment = mail.attachments["getbenefitshelp.pdf"]
      expect(pdf_attachment).to be_present
      expect(pdf_attachment.content_type).to start_with("application/pdf")
      expect(pdf_attachment.body.decoded).not_to be_empty
    end
  end

  describe "send_screener_results for DE zips" do
    before { allow_any_instance_of(Screener).to receive(:pdf).and_return("PDF") }

    context "with a single-office zip" do
      let(:screener) { create(:screener, state: "DE", zip_code: "19703", last_name: "Anyone", email: "preview@example.com") }
      let(:outgoing_email) { create(:outgoing_email, screener: screener) }
      let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }

      it "renders the single office in html and text" do
        html = html_body(mail)
        text = text_body(mail)

        [html, text].each do |body|
          expect(body).to include("3301 Green Street")
          expect(body).to include("Claymont, DE 19703")
          expect(body).to include("(302) 798-4093")
          expect(body).not_to include("If you live")
        end
      end
    end

    context "with a special_geo zip" do
      let(:screener) { create(:screener, state: "DE", zip_code: "19720", last_name: "Anyone", email: "preview@example.com") }
      let(:outgoing_email) { create(:outgoing_email, screener: screener) }
      let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }

      context "instructions section" do
        context "when state is DE" do
          it "includes DE ASSIST instructions" do
            expect(html_body(mail)).to include(I18n.t("views.screener_mailer.send_screener_results.online_submit_de_html"))
            expect(html_doc(mail).text).to include(I18n.t("views.screener_mailer.send_screener_results.online_county", website_name: I18n.t("views.screener_mailer.send_screener_results.website_name_de"), website: ""))
          end
        end
      end

      it "renders each office's subgeography, address, and phone in html and text" do
        html = html_body(mail)
        text = text_body(mail)

        [html, text].each do |body|
          expect(body).to include("If you live north of I-295")
          expect(body).to include("If you live south of I-295")
          expect(body).to include("500 Rogers Road")
          expect(body).to include("84 Christiana Road")
          expect(body).to include("(302) 622-4500")
          expect(body).to include("(800) 372-2022")
        end
      end
    end
  end
end

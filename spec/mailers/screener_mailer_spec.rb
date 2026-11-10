require "rails_helper"

RSpec.describe ScreenerMailer, type: :mailer do
  describe "send_screener_results" do
    states = {
      LocationData::States::NORTH_CAROLINA => {county: "Durham County"},
      LocationData::States::DELAWARE => {zip_code: "19703"}
    }

    before { allow_any_instance_of(Screener).to receive(:pdf).and_return("PDF") }

    let(:screener) { create(:screener, :with_nc_screener, :with_exemption) }
    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }
    let(:body) { html_body(mail) }

    it_behaves_like "a mailer with default headers"

    it "renders the headers and body" do
      screener.update(first_name: "Jean", last_name: "Jomp", confirmation_code: "ABC123")
      expect(mail.subject).to eq(I18n.t("views.screener_mailer.send_screener_results.subject"))
      [body, text_body(mail)].each do |content|
        expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.greeting", first_name: "Jean", last_name: "Jomp"))
        expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.attachment_notice"))
        expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.next_step_heading"))
        expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.reference_code", code: "ABC123"))
      end
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

      context "when the office has an email" do
        it "includes the office email" do
          screener.update(county: "Ashe County")
          [body, text_body(mail)].each do |content|
            expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.online_county_with_email", email: "dssinfo@ashecountygov.com"))
            expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.email_office", email: "dssinfo@ashecountygov.com"))
          end
        end
      end

      context "when the office does not have an email" do
        let(:online_county_with_email_prefix) { I18n.t("views.screener_mailer.send_screener_results.online_county_with_email", email: "") }
        let(:email_office_prefix) { I18n.t("views.screener_mailer.send_screener_results.email_office", email: "").delete_suffix(",") }

        it "does not include instructions for emailing" do
          [body, text_body(mail)].each do |content|
            expect(content).not_to include(online_county_with_email_prefix)
            expect(content).not_to include(email_office_prefix)
          end
        end
      end

      context "when the office has a website" do
        it "includes the office website" do
          [body, text_body(mail)].each do |content|
            expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.check_website", website: "https://dconc.gov/Social-Services/Food-and-Nutrition-Services"))
          end
        end
      end

      context "when the office does not have a website" do
        let(:check_website_prefix) { I18n.t("views.screener_mailer.send_screener_results.check_website", website: "").delete_suffix(",") }

        it "does not include instructions for checking the website" do
          screener.update(state: "DE", zip_code: "19703")
          [body, text_body(mail)].each do |content|
            expect(content).not_to include(check_website_prefix)
          end
        end
      end

      context "when the office has a phone number" do
        it "includes the office phone number" do
          [body, text_body(mail)].each do |content|
            expect(content).to include(I18n.t("views.screener_mailer.send_screener_results.call_office", phone: "919-560-8000"))
          end
        end
      end

      context "when the office does not have a phone number" do
        let(:call_office_prefix) { I18n.t("views.screener_mailer.send_screener_results.call_office", phone: "").delete_suffix(".") }

        it "does not include instructions for calling the office" do
          # there are currently no counties that lack a phone number
          allow(screener).to receive(:offices_to_display).and_return([LocationData::Counties.get("NC", "Durham County").merge(phone: nil)])
          [body, text_body(mail)].each do |content|
            expect(content).not_to include(call_office_prefix)
          end
        end
      end
    end

    context "proof section" do
      let(:student_html) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_html") }
      let(:student_text) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.student_text") }
      let(:proof_of_health_form_html) { I18n.t("views.proof_guidance.edit.proof_of_health_form_nc") }
      let(:proof_of_health_form_text) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.proof_of_health_form_text_nc") }
      let(:health_condition_html) { I18n.t("views.proof_guidance.edit.proof_of_health_condition_html", proof_of_health_form: proof_of_health_form_html, proof_of_condition_title: condition_title, condition_type: condition_type) }
      let(:health_condition_text) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.health_condition_text", proof_of_health_form: proof_of_health_form_text, proof_of_condition_title: condition_title, condition_type: condition_type) }
      let(:disability_benefits_html) { I18n.t("views.proof_guidance.edit.proof_of_disability_benefits_html") }
      let(:disability_benefits_text) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.disability_benefits_title") }
      let(:treatment_program_html) { I18n.t("views.proof_guidance.edit.proof_of_treatment_program_html") }
      let(:treatment_program_text) { I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.treatment_program_text") }

      context "when is_student is yes" do
        it "includes proof of education" do
          screener.update(is_student: "yes")
          expect(body).to include(student_html)
          expect(text_body(mail)).to include(student_text)
        end
      end

      context "when is_student is not yes" do
        it "does not include proof of education" do
          screener.update(is_student: "no")
          expect(body).not_to include(student_html)
          expect(text_body(mail)).not_to include(student_text)
        end
      end

      context "when preventing_work_drugs_alcohol and preventing_work_medical_condition are yes" do
        let(:condition_title) { I18n.t("views.proof_guidance.edit.proof_of_health_and_substance_use_condition_title") }
        let(:condition_type) { I18n.t("views.proof_guidance.edit.condition_medical_health") }

        it "includes proof of health and substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "yes", preventing_work_medical_condition: "yes")
          expect(body).to include(health_condition_html)
          expect(text_body(mail)).to include(health_condition_text)
        end
      end

      context "when preventing_work_drugs_alcohol is yes and preventing_work_medical_condition is no" do
        let(:condition_title) { I18n.t("views.proof_guidance.edit.proof_of_substance_use_condition_only_title") }
        let(:condition_type) { I18n.t("views.proof_guidance.edit.condition_substance_use") }

        it "includes proof of only substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "yes", preventing_work_medical_condition: "no")
          expect(body).to include(health_condition_html)
          expect(text_body(mail)).to include(health_condition_text)
        end
      end

      context "when preventing_work_medical_condition is yes and preventing_work_drugs_alcohol is no" do
        let(:condition_title) { I18n.t("views.proof_guidance.edit.proof_of_health_condition_only_title") }
        let(:condition_type) { I18n.t("views.proof_guidance.edit.condition_medical_health") }

        it "includes proof of only health conditions" do
          screener.update(preventing_work_medical_condition: "yes", preventing_work_drugs_alcohol: "no")
          expect(body).to include(health_condition_html)
          expect(text_body(mail)).to include(health_condition_text)
          expect(text_body(mail)).not_to include("%>")
        end
      end

      context "when preventing_work_drugs_alcohol and preventing_work_medical_condition are no" do
        it "does not include proof of health or substance conditions" do
          screener.update(preventing_work_drugs_alcohol: "no", preventing_work_medical_condition: "no")
          expect(body).not_to include(proof_of_health_form_html)
          expect(text_body(mail)).not_to include(proof_of_health_form_text)
        end
      end

      states.each do |state, location|
        context "when state is #{state} and preventing_work_medical_condition is yes" do
          it "includes the state's health form" do
            screener.update(state: state, **location, preventing_work_medical_condition: "yes")
            expect(body).to include(I18n.t("views.proof_guidance.edit.proof_of_health_form_#{state.downcase}"))
            expect(text_body(mail)).to include(I18n.t("views.screener_mailer.send_screener_results.proofs_you_may_need.proof_of_health_form_text_#{state.downcase}"))
          end
        end
      end

      context "when receiving disability benefits" do
        it "includes proof of disability benefits with selected benefits only" do
          screener.update(receiving_benefits_ssdi: "yes", receiving_benefits_ssi: "yes", receiving_benefits_other: "yes", receiving_benefits_write_in: "Many bennies")

          expect(body).to include(disability_benefits_html)
          expect(text_body(mail)).to include(disability_benefits_text)
          [body, text_body(mail)].each do |content|
            expect(content).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssdi"))
            expect(content).to include(I18n.t("views.disability_benefits.edit.receiving_benefits_ssi"))
            expect(content).to include("Many bennies")
            expect(content).not_to include(I18n.t("views.disability_benefits.edit.receiving_benefits_veterans_disability"))
          end
        end
      end

      context "when not receiving any disability benefits" do
        it "does not include proof of disability benefits" do
          expect(body).not_to include(disability_benefits_html)
          expect(text_body(mail)).not_to include(disability_benefits_text)
        end
      end

      context "when is_in_alcohol_treatment_program is yes" do
        it "includes proof of treatment program" do
          screener.update(is_in_alcohol_treatment_program: "yes")
          expect(body).to include(treatment_program_html)
          expect(text_body(mail)).to include(treatment_program_text)
        end
      end

      context "when is_in_alcohol_treatment_program is not yes" do
        it "does not include proof of treatment program" do
          screener.update(is_in_alcohol_treatment_program: "no")
          expect(body).not_to include(treatment_program_html)
          expect(text_body(mail)).not_to include(treatment_program_text)
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

require "rails_helper"

RSpec.describe SurveyMailer, type: :mailer do
  describe "send_survey" do
    let(:state) { LocationData::States::NORTH_CAROLINA }
    let(:locale) { "en" }

    let(:screener) do
      create(:screener, state: state, email: "hi@example.com", locale: locale)
    end

    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) { SurveyMailer.send_survey(outgoing_email: outgoing_email) }
    let(:body) { html_body(mail) }

    it_behaves_like "a mailer with default headers"

    it "renders headers and body" do
      expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject"))
      expect(html_doc(mail).text).to include(I18n.t("views.survey_mailer.send_survey.greeting"))
      expect(html_doc(mail).text).to include(I18n.t("views.survey_mailer.send_survey.paragraph_2"))
    end

    context "when state is NC" do
      it "includes NC survey link" do
        expect(body).to include(LocationData::States::STATES_INFO[state][:survey_url])
        expect(body).to include("Take this 2-minute survey")
      end
    end

    context "when state is DE" do
      let(:state) { LocationData::States::DELAWARE }

      it "includes DE survey link" do
        expect(body).to include(LocationData::States::STATES_INFO[state][:survey_url])
        expect(body).to include("Take this 2-minute survey")
      end
    end

    context "when the screener's locale is en" do
      it "renders the English subject and body" do
        expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject", locale: :en))
        expect(html_doc(mail).text).to include(I18n.t("views.survey_mailer.send_survey.greeting", locale: :en))
      end
    end

    context "when the screener's locale is es" do
      let(:locale) { "es" }

      it "renders the Spanish subject and body" do
        expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject", locale: :es))
        expect(html_doc(mail).text).to include(I18n.t("views.survey_mailer.send_survey.greeting", locale: :es))
      end

      it "renders in Spanish even when enqueued with no ambient locale set (e.g. Solid Queue's recurring scheduler)" do
        expect(I18n.locale).to eq(:en) # RSpec's default; nothing here has set a request-driven locale

        expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject", locale: :es))
        expect(mail.subject).not_to eq(I18n.t("views.survey_mailer.send_survey.subject", locale: :en))
      end

      it "restores the ambient locale afterward" do
        mail.subject

        expect(I18n.locale).to eq(:en)
      end
    end

    context "when the screener has no locale" do
      let(:locale) { nil }

      it "falls back to the default locale" do
        expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject", locale: I18n.default_locale))
      end
    end
  end
end

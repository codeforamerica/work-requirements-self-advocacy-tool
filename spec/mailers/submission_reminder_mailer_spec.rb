require "rails_helper"

RSpec.describe SubmissionReminderMailer, type: :mailer do
  describe "send_reminder" do
    let(:locale) { "en" }
    let(:state) { LocationData::States::NORTH_CAROLINA }
    let(:screener) do
      create(:screener, state: state, email: "hi@example.com", locale: locale)
    end

    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) { SubmissionReminderMailer.send_reminder(outgoing_email: outgoing_email) }
    let(:body) { html_body(mail) }

    it_behaves_like "a mailer with default headers"

    it "sends to the screener's email address" do
      expect(mail.to).to eq(["hi@example.com"])
    end

    context "rendering state-specific portal" do
      [
        [LocationData::States::NORTH_CAROLINA, I18n.t("views.submission_reminder_mailer.send_reminder.online_portal_nc")],
        [LocationData::States::DELAWARE, I18n.t("views.submission_reminder_mailer.send_reminder.online_portal_de")]
      ].each do |state, portal|
        context state.to_s do
          let(:state) { state }

          it "renders the correct submission portal" do
            expect(html_doc(mail).text).to include(portal)
          end
        end
      end
    end

    context "when the screener's locale is en" do
      it "renders the English subject and body" do
        expect(mail.subject).to eq(I18n.t("views.submission_reminder_mailer.send_reminder.subject", locale: :en))
        expect(html_doc(mail).text).to include(I18n.t("views.submission_reminder_mailer.send_reminder.intro", locale: :en))
      end
    end

    context "when the screener's locale is es" do
      let(:locale) { "es" }

      it "renders the Spanish subject and body" do
        expect(mail.subject).to eq(I18n.t("views.submission_reminder_mailer.send_reminder.subject", locale: :es))
        expect(html_doc(mail).text).to include(I18n.t("views.submission_reminder_mailer.send_reminder.intro", locale: :es))
      end
    end

    context "when the screener has no locale" do
      let(:locale) { nil }

      it "falls back to the default locale" do
        expect(mail.subject).to eq(I18n.t("views.submission_reminder_mailer.send_reminder.subject", locale: I18n.default_locale))
      end
    end
  end
end

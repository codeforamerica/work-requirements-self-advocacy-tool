require "rails_helper"

RSpec.describe SurveyMailer, type: :mailer do
  describe "send_survey" do
    let(:state) { LocationData::States::NORTH_CAROLINA }

    let(:screener) do
      create(:screener, state: state, email: "hi@example.com")
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

    context "when state is unsupported" do
      let(:state) { "TX" }

      it "raises an error" do
        expect { mail.deliver_now }.to raise_error(KeyError)
      end
    end
  end
end

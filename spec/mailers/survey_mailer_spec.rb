require "rails_helper"

RSpec.describe SurveyMailer, type: :mailer do
  describe "send_survey" do
    let(:state) { LocationData::States::NORTH_CAROLINA }
    let(:screener) do
      create(:screener, state: state, email: "hi@example.com")
    end
    let(:outgoing_email) { create(:outgoing_email, screener: screener) }
    let(:mail) do
      SurveyMailer.send_survey(outgoing_email: outgoing_email)
    end
    let(:body) { mail.html_part.body.to_s }

    it "renders headers and body" do
      expect(mail.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject"))
      expect(mail.from).to eq(["noreply@codeforamerica.app"])

      doc = Nokogiri::HTML(body)
      expect(doc.text).to include(I18n.t("views.survey_mailer.send_survey.greeting"))
      expect(doc.text).to include(I18n.t("views.survey_mailer.send_survey.paragraph_2"))
    end

    context "when state is NC" do
      it "includes NC survey link" do
        expect(body).to include("https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3kgHxveKeorfFC6")
        expect(body).to include("Take this 2-minute survey")
      end
    end

    context "when state is DE" do
      let(:state) { LocationData::States::DELAWARE }

      it "includes DE survey link" do
        expect(body).to include("https://codeforamerica.co1.qualtrics.com/jfe/form/SV_8rdcUjhPOWA0XzM")
        expect(body).to include("Take this 2-minute survey")
      end
    end

    context "when state is unsupported" do
      let(:state) { "TX" }

      it "raises an error" do
        expect { mail.deliver_now }.to raise_error(KeyError)
      end
    end

    it "attaches the inline header image" do
      attachment = mail.attachments["gbh_email_header.png"]

      expect(attachment).to be_present
      expect(attachment.content_type).to start_with("image/png")
      expect(attachment.body.decoded).not_to be_empty
    end
  end
end

require "rails_helper"

RSpec.describe ScreenerMailer, type: :mailer do
  describe "download_pdf" do
    let(:outgoing_email) { create(:outgoing_email, screener: create(:screener))}
    let(:mail) { ScreenerMailer.download_pdf(outgoing_email: outgoing_email) }

    it "renders the headers" do
      expect(mail.subject).to eq("[GetBenefitsHelp] Your SNAP Work Rules form")
      expect(mail.from).to eq(["noreply@getbenefitshelp.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Submit this form and any proof you need to your SNAP agency")
    end
  end
end

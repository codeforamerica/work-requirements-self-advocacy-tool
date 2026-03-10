require "rails_helper"

RSpec.describe ScreenerMailer, type: :mailer do
  describe "send_screener_results" do
    let(:outgoing_email) { create(:outgoing_email, screener: create(:screener)) }
    let(:mail) { ScreenerMailer.send_screener_results(outgoing_email: outgoing_email) }

    it "renders the headers and body" do
      expect(mail.subject).to eq("[GetBenefitsHelp] Your SNAP Work Rules form")
      expect(mail.from).to eq(["noreply@" + ENV.fetch("DOMAIN", "codeforamerica.app")])
      expect(mail.body.encoded).to include("Submit this form and any proof you need to your SNAP agency")
    end
  end
end

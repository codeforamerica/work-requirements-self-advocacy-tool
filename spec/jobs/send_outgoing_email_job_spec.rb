require "rails_helper"

RSpec.describe SendOutgoingEmailJob, type: :job do
  describe "#perform" do
    let(:email_address) { "hi@example.com" }
    let(:outgoing_email) { create(:outgoing_email, screener: create(:screener, email: email_address)) }

    it "finds the outgoing email and sends an email" do
      expect { described_class.perform_now(outgoing_email.id) }.to change(ActionMailer::Base.deliveries, :count).by(1)
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq [email_address]
      expect(email.body.encoded).to include("Submit this form and any proof you need to your SNAP agency")
      expect(outgoing_email.reload.sent_at).to be_present
    end
  end
end

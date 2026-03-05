require 'rails_helper'

RSpec.describe SendOutgoingEmailJob, type: :job do
  describe '#perform' do
    let(:outgoing_email) { create(:outgoing_email, screener: create(:screener)) }
    let(:message_id) { "some_fake_id"}
    let(:mailer) { double(ScreenerMailer) }

    before do
      allow(ScreenerMailer).to receive(:download_pdf).and_return(mailer)
      allow(mailer).to receive(:deliver_now).and_return Mail::Message.new(message_id: message_id)
    end

    it 'finds the outgoing email and sends an email' do
      described_class.perform_now(outgoing_email.id)
      expect(ScreenerMailer).to have_received(:download_pdf).with(outgoing_email: outgoing_email)
      expect(outgoing_email.reload.sent_at).to be_present
    end
  end
end

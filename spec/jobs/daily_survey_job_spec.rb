require "rails_helper"

RSpec.describe DailySurveyJob, type: :job do
  describe "#perform" do
    let(:email_address) { "hi@example.com" }

    let!(:screener) do
      create(
        :screener,
        :with_exemption,
        state: "NC",
        email: email_address,
        signed_at: signed_at,
        nc_screener: create(:nc_screener)
      )
    end

    let(:signed_at) do
      Time.use_zone("America/Los_Angeles") do
        Date.yesterday.middle_of_day
      end
    end

    # it "finds eligible screeners and sends survey emails" do
    #   expect { described_class.perform_now }
    #     .to change(ActionMailer::Base.deliveries, :count).by(1)
    #     .and change(OutgoingEmail, :count).by(1)
    #
    #   email = ActionMailer::Base.deliveries.last
    #   outgoing_email = OutgoingEmail.last
    #
    #   expect(email.to).to eq [email_address]
    #   expect(email.subject).to eq(I18n.t("views.survey_mailer.send_survey.subject"))
    #   expect(outgoing_email.screener).to eq(screener)
    #   expect(outgoing_email.sent_at).to be_present
    # end

    it "does not send emails for screeners without email addresses" do
      screener.update(email: nil)

      expect { described_class.perform_now }.not_to change(ActionMailer::Base.deliveries, :count)
      expect(OutgoingEmail.count).to eq(0)
    end

    it "does not send emails for screeners with empty email addresses" do
      screener.update(email: "")

      expect { described_class.perform_now }.not_to change(ActionMailer::Base.deliveries, :count)
      expect(OutgoingEmail.count).to eq(0)
    end

    it "does not send emails for screeners outside the signed_at range" do
      screener.update(signed_at: 30.days.ago)

      expect { described_class.perform_now }
        .not_to change(ActionMailer::Base.deliveries, :count)

      expect(OutgoingEmail.count).to eq(0)
    end

    # it "continues processing if sending an email raises an error" do
    #   allow(SurveyMailer).to receive(:send_survey).and_raise(StandardError.new("boom"))
    #
    #   expect { described_class.perform_now }.not_to raise_error
    #
    #   outgoing_email = OutgoingEmail.last
    #   expect(outgoing_email.sent_at).to be_nil
    # end
  end
end

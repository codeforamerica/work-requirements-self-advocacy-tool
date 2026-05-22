RSpec.shared_examples "a mailer with default headers" do
  it "uses the default from address" do
    expect(mail.from).to eq(["noreply@#{ENV.fetch("DOMAIN", "codeforamerica.app")}"])
  end

  it "attaches the inline header image" do
    attachment = mail.attachments["gbh_email_header.png"]

    expect(attachment).to be_present
    expect(attachment.content_type).to start_with("image/png")
    expect(attachment.body.decoded).not_to be_empty
  end
end

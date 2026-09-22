require "rails_helper"

RSpec.describe "Intercom chat button", type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("INTERCOM_APP_ID").and_return("test_app_id")
    allow(IntercomRails.config).to receive(:enabled_environments).and_return(["test"])
  end

  it "loads the messenger for a visitor with no screener" do
    get "/es"

    expect(response).to have_http_status(:success)
    expect(response.body).to include("Iniciar chat")
    expect(response.body).to include('class="intercom button button--small"')
    expect(response.body).to include('"language_override":"es"')
  end

  it "does not show the button when INTERCOM_APP_ID is not configured" do
    allow(ENV).to receive(:[]).with("INTERCOM_APP_ID").and_return(nil)

    get "/"

    expect(response.body).not_to include("Start chat")
  end

  it "does not show the button when the current environment is not enabled for Intercom" do
    allow(IntercomRails.config).to receive(:enabled_environments).and_return([])

    get "/"

    expect(response.body).not_to include("Start chat")
  end

  describe "the auto-included Intercom script" do
    it "carries a nonce matching the page's CSP header" do
      get "/"

      nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
      expect(nonce).to be_present
      expect(response.body).to include(%(id="IntercomSettingsScriptTag" nonce="#{nonce}"))
    end

    it "sets language_override from the screener once one exists" do
      get "/es/start_flow"
      follow_redirect! while response.redirect?

      expect(response.body).to include('"language_override":"es"')
    end
  end

  it "allowlists the Intercom domains needed for the widget in the CSP header" do
    get "/"

    csp = response.headers["Content-Security-Policy"]
    expect(csp).to include("https://widget.intercom.io")
    expect(csp).to include("https://api-iam.intercom.io")
    expect(csp).to include("wss://nexus-websocket-a.intercom.io")
  end
end

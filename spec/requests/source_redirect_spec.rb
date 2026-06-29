require "rails_helper"

RSpec.describe "source redirect", type: :request do
  it "expands the source parameter" do
    get "/s/sfsu"
    expect(response).to redirect_to "/?source=sfsu"
  end

  it "preserves the locale" do
    get "/es/s/sfsu"
    expect(response).to redirect_to "/es?source=sfsu"
  end

  it "does not allow ampersand injection into the redirect URL" do
    get "/en/s/legitimate_source%26injected_param=malicious_value"
    expect(response.location).not_to include("&injected_param=")
    expect(response.location).to include("source=legitimate_source%26injected_param%3Dmalicious_value")
  end

  it "does not allow fragment injection into the redirect URL" do
    get "/en/s/test%23injected_fragment"
    expect(response.location).not_to include("#injected_fragment")
    expect(response.location).to include("source=test%23injected_fragment")
  end
end

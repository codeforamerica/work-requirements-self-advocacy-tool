require "rails_helper"

RSpec.describe "ParameterTypeError handling", type: :request do
  it "returns 400 when query parameters have conflicting types" do
    get "/en/location?screener=bad&screener[state]=NC"
    expect(response).to have_http_status(:bad_request)
  end
end

require "rails_helper"

RSpec.describe "Mime::Type::InvalidMimeType handling", type: :request do
  it "returns 406 instead of 500 for a garbage Accept header" do
    get "/en/location", headers: {"HTTP_ACCEPT" => "sleep 4"}
    expect(response).to have_http_status(:not_acceptable)
  end
end

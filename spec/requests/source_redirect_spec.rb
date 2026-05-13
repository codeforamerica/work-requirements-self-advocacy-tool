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
end

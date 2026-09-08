require "rails_helper"

RSpec.describe "about page", type: :request do
  it "renders content in English" do
    get "/about"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("views.about.show.title", locale: :en))
    expect(response.body).to include(I18n.t("views.about.show.ready.title", locale: :en))
  end

  it "renders content in Spanish" do
    get "/es/about"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("views.about.show.title", locale: :es))
    expect(response.body).to include(I18n.t("views.about.show.ready.title", locale: :es))
  end

  it "links to the privacy policy and the start of the flow" do
    get "/about"

    expect(response.body).to include(%(href="/en/privacy_policy"))
    expect(response.body).to include(%(href="/en/start_flow"))
  end

  it "is linked from the footer" do
    get "/"
    expect(response.body).to include(about_path)
  end
end

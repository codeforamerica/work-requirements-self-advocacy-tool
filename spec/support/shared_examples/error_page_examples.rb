RSpec.shared_examples "an error page in English" do
  it "shows the contact email as a mailto link" do
    expect(response.body).to include('href="mailto:getbenefitshelp@codeforamerica.org"')
  end

  it "shows the English CTA" do
    expect(response.body).to include("Go to home page")
  end
end

RSpec.shared_examples "an error page in Spanish" do
  it "shows the Spanish CTA" do
    expect(response.body).to include("Volver al inicio")
  end

  it "shows the contact email as a mailto link" do
    expect(response.body).to include('href="mailto:getbenefitshelp@codeforamerica.org"')
  end
end

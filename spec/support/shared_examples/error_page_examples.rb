RSpec.shared_examples "an error page" do |locale|
  it "shows the contact email as a mailto link" do
    expect(response.body).to include('href="mailto:getbenefitshelp@codeforamerica.org"')
  end

  if locale == :es
    it "shows the Spanish CTA" do
      expect(response.body).to include("Volver al inicio")
    end
  else
    it "shows the English CTA" do
      expect(response.body).to include("Go to home page")
    end
  end
end

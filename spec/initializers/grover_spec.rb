require "rails_helper"

# Runs headless Chrome for real, unlike the PdfFiller specs, which stub Grover out.
RSpec.describe "Grover configuration" do
  it "renders the HTML it is given rather than the page at its display URL" do
    html = Grover.new("<html><body><h1>Rendered by Grover</h1></body></html>").to_html

    expect(html).to include("Rendered by Grover")
    expect(html).not_to include("documentation examples")
  end
end

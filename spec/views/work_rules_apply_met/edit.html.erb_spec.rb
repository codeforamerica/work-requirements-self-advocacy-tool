require "rails_helper"

RSpec.describe "work_rules_apply_met/edit", type: :view do
  let(:screener) { create(:screener) }

  before do
    assign(:current_screener, screener)
    without_partial_double_verification do
      allow(view).to receive(:next_path).and_return("/next")
    end
  end

  it "always displays the title and proof of working " do
    render
    expect(rendered).to include(I18n.t("views.work_rules_apply_met.edit.title"))
    expect(rendered).to include(I18n.t("views.work_rules_apply_met.edit.proof_of_working_html"))
  end

  describe "proof of volunteering section" do
    it "shows section when needs_proof_of_volunteering? is true" do
      allow(screener).to receive(:needs_proof_of_volunteering?).and_return(true)
      render
      expect(rendered).to include(I18n.t("views.work_rules_apply_met.edit.proof_of_volunteering"))
      expect(rendered).to include(I18n.t("views.work_rules_apply_met.edit.proof_of_volunteering_html"))
    end

    it "shows section when needs_proof_of_volunteering? is false" do
      allow(screener).to receive(:needs_proof_of_volunteering?).and_return(false)
      render
      expect(rendered).not_to include(I18n.t("views.work_rules_apply_met.edit.proof_of_volunteering"))
      expect(rendered).not_to include(I18n.t("views.work_rules_apply_met.edit.proof_of_volunteering_html"))
    end
  end
end

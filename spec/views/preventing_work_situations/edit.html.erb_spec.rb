require "rails_helper"

RSpec.describe "preventing_work_situations/edit", type: :view do
  let(:screener) { create(:screener) }

  before do
    assign(:current_screener, screener)
    assign(:model, screener)
    without_partial_double_verification do
      allow(view).to receive(:next_path).and_return("/next")
    end
  end

  it "always displays the title" do
    render
    expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.title"))
  end

  describe "situations checkbox section" do
    it "shows all 6 checkboxes when state is NC" do
      render
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.preventing_work_place_to_sleep"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.preventing_work_drugs_alcohol"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.preventing_work_domestic_violence"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.preventing_work_medical_condition_html"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.other"))
      expect(rendered).to include(I18n.t("general.none_of_the_above"))
    end

    it "shows all 6 checkboxes when state is not NC" do
      screener.update(state: "DE")

      render
      expect(rendered).not_to include(I18n.t("views.preventing_work_situations.edit.preventing_work_place_to_sleep"))
      expect(rendered).not_to include(I18n.t("views.preventing_work_situations.edit.preventing_work_drugs_alcohol"))
      expect(rendered).not_to include(I18n.t("views.preventing_work_situations.edit.preventing_work_domestic_violence"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.preventing_work_medical_condition_html"))
      expect(rendered).to include(I18n.t("views.preventing_work_situations.edit.other"))
      expect(rendered).to include(I18n.t("general.none_of_the_above"))
    end
  end
end

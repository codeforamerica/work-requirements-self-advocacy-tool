require "rails_helper"

RSpec.describe GetBenefitsHelpFormBuilder do
  describe "#cfa_memorable_date" do
    let(:screener) { build(:screener, birth_date: Date.new(2000, 1, 19)) }
    let(:builder) { described_class.new("screener", screener, ActionController::Base.new.view_context, {}) }
    let(:fieldset) { Nokogiri::HTML(builder.cfa_memorable_date(:birth_date, "Birth date", help_text: "Help")).at_css("fieldset.memorable-date") }

    it "shows the error and links it to the fieldset when the date is invalid" do
      screener.birth_date = nil
      screener.valid?(:basic_info_details)

      expect(fieldset["class"]).to include("form-group--error")
      expect(fieldset["aria-describedby"].split).to include("screener_birth_date__errors")
      expect(fieldset.at_css("#screener_birth_date__errors").text).to include(I18n.t("validations.date_missing_or_invalid"))
    end

    it "shows month names in Spanish" do
      options = I18n.with_locale(:es) { fieldset.css("select[name='screener[birth_date_month]'] option").map(&:text) }

      expect(options).to include("enero", "septiembre", "diciembre")
    end
  end
end

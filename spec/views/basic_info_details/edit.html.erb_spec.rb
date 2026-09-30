require "rails_helper"

RSpec.describe "basic_info_details/edit", type: :view do
  let(:screener) { create(:screener, birth_date: Date.new(2000, 1, 19)) }

  before do
    assign(:current_screener, screener)
    assign(:model, screener)
  end

  it "renders the birthdate as a month select and day and year text inputs" do
    render
    html = Nokogiri::HTML(rendered)

    fieldset = html.at_css("fieldset.memorable-date")
    expect(fieldset.at_css("legend").text.strip).to eq I18n.t("views.basic_info_details.edit.birth_date_label")
    expect(fieldset.text).to include(I18n.t("views.basic_info_details.edit.birth_date_help_text"))

    month = fieldset.at_css("select[name='screener[birth_date_month]']")
    expect(month.css("option").map(&:text)).to eq [I18n.t("general.select"), *I18n.t("date.month_names").compact]
    expect(month.at_css("option[selected]")["value"]).to eq "1"

    day = fieldset.at_css("input[name='screener[birth_date_day]']")
    expect(day.attributes.transform_values(&:value)).to include("inputmode" => "numeric", "maxlength" => "2", "value" => "19")

    year = fieldset.at_css("input[name='screener[birth_date_year]']")
    expect(year.attributes.transform_values(&:value)).to include("inputmode" => "numeric", "maxlength" => "4", "value" => "2000")

    %w[month day year].each do |position|
      expect(fieldset.at_css("label[for='screener_birth_date_#{position}']").text).to eq I18n.t("honeycrisp.#{position}")
    end
  end

  it "shows the error and links it to the fieldset when the date is invalid" do
    screener.birth_date = nil
    screener.valid?(:basic_info_details)
    render
    fieldset = Nokogiri::HTML(rendered).at_css("fieldset.memorable-date")

    expect(fieldset["class"]).to include("form-group--error")
    expect(fieldset["aria-describedby"].split).to include("screener_birth_date__errors")
    expect(fieldset.at_css("#screener_birth_date__errors").text).to include(I18n.t("validations.date_missing_or_invalid"))
  end
end

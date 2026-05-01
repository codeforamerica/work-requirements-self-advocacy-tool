require "rails_helper"

RSpec.describe OutOfStateController, type: :controller do
  # Only NC has counties
  let(:state_with_counties) { LocationData::States::NORTH_CAROLINA }

  def all_nc_counties
    LocationData::Counties.for_state(state_with_counties).values
  end

  def supported_counties
    all_nc_counties.select { |c| c[:is_supported] }
  end

  def unsupported_counties
    all_nc_counties.reject { |c| c[:is_supported] }
  end

  def county_name(county)
    county[:name]
  end

  describe ".not_listed?" do
    it "returns true when state is NOT_LISTED" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      expect(described_class.not_listed?(screener)).to eq(true)
    end

    it "returns false for a normal state" do
      screener = create(:screener, state: state_with_counties)
      expect(described_class.not_listed?(screener)).to eq(false)
    end
  end

  describe ".county_not_supported?" do
    it "returns false when county is nil" do
      screener = create(:screener, state: state_with_counties, county: nil)
      expect {
        described_class.county_not_supported?(screener)
      }.to raise_error(ArgumentError, /county_key is required/)
    end

    it "returns false for supported counties" do
      county = supported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      expect(described_class.county_not_supported?(screener)).to eq(false)
    end

    it "returns true for unsupported counties" do
      county = unsupported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      expect(described_class.county_not_supported?(screener)).to eq(true)
    end
  end

  describe ".show?" do
    it "returns true if state is NOT_LISTED" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns true if county is not supported" do
      county = unsupported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      expect(described_class.show?(screener)).to eq(true)
    end

    it "returns false when county is supported" do
      county = supported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      expect(described_class.show?(screener)).to eq(false)
    end
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
  end

  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit

    render_views

    it "not_listed? view" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      sign_in screener

      get :edit

      expect(response.body).to include(I18n.t("views.out_of_state.edit.title_help_text_html"))
    end

    it "county specific view" do
      county = supported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      sign_in screener

      get :edit

      expect(response.body).not_to include(I18n.t("views.out_of_state.edit.title_help_text_html"))
      expect(response.body).to include(I18n.t("views.out_of_state.edit.contact_redirect", seconds: controller.redirect_delay_seconds))
    end
  end
end

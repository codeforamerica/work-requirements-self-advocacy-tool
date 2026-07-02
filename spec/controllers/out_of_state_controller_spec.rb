require "rails_helper"

RSpec.describe OutOfStateController, type: :controller do
  # Only NC has counties
  let(:state_with_counties) { LocationData::States::NORTH_CAROLINA }

  # This adds a single fake county for the tests, and it is a county that is not supported
  # because all 100 counties for NC are currently supported
  before do
    fake_county = {
      name: "FAKE COUNTY",
      mailing_address: "123 Main Street",
      physical_address: "123 Main Street",
      phone: "555-555-5555",
      fax: "123-123-1234",
      email: "fake@fake",
      website: "www.fake",
      upload_portal_or_email: "fake@fake",
      is_supported: false
    }

    modified_counties = LocationData::Counties::ALL_COUNTIES.deep_dup
    modified_counties[state_with_counties]["FAKE COUNTY"] = fake_county

    stub_const(
      "LocationData::Counties::ALL_COUNTIES",
      modified_counties
    )
  end

  let(:all_nc_counties) { LocationData::Counties.for_state(state_with_counties).values }
  let(:supported_counties) { all_nc_counties.select { |c| c[:is_supported] } }
  let(:unsupported_counties) { all_nc_counties.reject { |c| c[:is_supported] } }

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
    context "a state whose offices are keyed by county" do
      it "returns false when county is nil" do
        screener = create(:screener, state: state_with_counties, county: nil)
        expect {
          described_class.county_not_supported?(screener)
        }.to raise_error(ArgumentError, /county_key is required/)
      end

      it "returns false for supported counties" do
        county = supported_counties.first
        screener = create(:screener, state: state_with_counties, county: county[:name])
        expect(described_class.county_not_supported?(screener)).to eq(false)
      end

      it "returns true for unsupported counties" do
        county = unsupported_counties.first
        screener = create(:screener, state: state_with_counties, county: county[:name])
        expect(described_class.county_not_supported?(screener)).to eq(true)
      end
    end

    context "a state whose offices are not keyed by county" do
      it "returns false" do
        screener = create(:screener, state: LocationData::States::DELAWARE, county: nil)
        expect(described_class.county_not_supported?(screener)).to eq false
      end
    end
  end

  describe ".show?" do
    it "returns true if state is NOT_LISTED" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      expect(described_class.show?(screener)).to eq(true)
    end

    context "a state whose offices are keyed by county" do
      it "returns true if county is not supported" do
        county = unsupported_counties.first
        screener = create(:screener, state: state_with_counties, county: county[:name])
        expect(described_class.show?(screener)).to eq(true)
      end

      it "returns false when county is supported" do
        county = supported_counties.first
        screener = create(:screener, state: state_with_counties, county: county[:name])
        expect(described_class.show?(screener)).to eq(false)
      end
    end

    context "a state whose offices are not keyed by county" do
      it "returns false" do
        screener = create(:screener, state: LocationData::States::DELAWARE, county: nil)
        expect(described_class.show?(screener)).to eq false
      end
    end
  end

  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display

    render_views

    it "not_listed? view" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      sign_in screener

      get :display

      expect(response.body).to include(I18n.t("views.out_of_state.edit.title_help_text_html"))
    end

    it "county specific view" do
      county = supported_counties.first
      screener = create(:screener, state: state_with_counties, county: county[:name])
      sign_in screener

      get :display

      expect(response.body).not_to include(I18n.t("views.out_of_state.edit.title_help_text_html"))
      expect(response.body).to include(I18n.t("views.out_of_state.edit.contact_redirect", seconds: controller.redirect_delay_seconds))
    end
  end
end

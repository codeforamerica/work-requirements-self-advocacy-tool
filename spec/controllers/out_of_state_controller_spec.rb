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
      expect(described_class.county_not_supported?(screener)).to eq(false)
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

  describe "helper methods" do
    it "exposes not_listed? to the view" do
      screener = create(:screener, state: LocationData::States::NOT_LISTED)
      controller.instance_variable_set(:@current_screener, screener)

      screener.reload
      expect(controller.view_context.not_listed?).to eq(true)
    end

    it "exposes county_not_supported? to the view" do
      county = unsupported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      controller.instance_variable_set(:@current_screener, screener)

      screener.reload
      expect(controller.view_context.county_not_supported?).to eq(true)
    end

    it "exposes county to the view" do
      county = supported_counties.first
      screener = create(:screener, state: state_with_counties, county: county_name(county))
      controller.instance_variable_set(:@current_screener, screener)

      screener.reload
      result = controller.view_context.county

      expect(result).to be_present
      expect(county_name(result)).to eq(county_name(county))
    end
  end
end

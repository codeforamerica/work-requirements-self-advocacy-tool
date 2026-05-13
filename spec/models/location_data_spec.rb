require "rails_helper"
require "csv"

RSpec.describe LocationData do
  describe LocationData::States do
    [:display_name, :pdf_filler_class].each do |getter_method|
      describe ".#{getter_method}" do
        described_class.active_states.keys.each do |state_code|
          it "defines the method for #{state_code}" do
            expect(described_class.send(getter_method, state_code)).not_to be_nil
          end

          it "throws an error for an invalid state code" do
            expect do
              described_class.send(getter_method, "boop")
            end.to raise_error(StandardError, "Invalid state code: boop")
          end
        end
      end
    end

    describe ".active_states" do
      it "returns only states whose code is listed in ACTIVE_STATES" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("ACTIVE_STATES").and_return("NC")

        expect(described_class.active_states.keys).to contain_exactly("NC")
      end

      it "returns an empty hash when ACTIVE_STATES is unset" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("ACTIVE_STATES").and_return(nil)

        expect(described_class.active_states).to eq({})
      end
    end

    describe ".dropdown_options" do
      it "returns state options including translated not listed" do
        allow(I18n).to receive(:t).with("views.location.edit.not_listed").and_return("Not listed")

        options = described_class.dropdown_options

        expect(options).to include(["North Carolina", "NC"])
        expect(options).to include(["Not listed", "NOT_LISTED"])
      end
    end
  end

  describe LocationData::Counties do
    let(:data_dir) { Rails.root.join("config/data/counties") }
    let(:all_counties) { described_class::ALL_COUNTIES }

    before do
      skip "County CSV files not found" unless Dir.exist?(data_dir)
    end

    it "loads CSV files for states that match offices to counties" do
      states = LocationData::States::STATES_INFO.select { |_, state_info| state_info[:office_by] == :county }.keys
      expect(all_counties.keys).to match_array(states)
    end

    describe "county counts" do
      it "reports correct number of counties per state" do
        all_counties.each do |state, counties|
          csv_file = data_dir.join("#{state}.csv")
          expected_count = File.exist?(csv_file) ? CSV.read(csv_file, headers: true).count { |row| row[LocationData::COUNTY_NAME]&.strip.present? } : 0
          expect(counties.size).to eq(expected_count)
        end
      end
    end

    describe ".for_state" do
      it "returns all counties from CSV for each state" do
        all_counties.each do |state, counties|
          expect(counties.keys).to all(satisfy { |k| k.is_a?(String) && !k.empty? })
        end
      end

      it "returns empty hash for a state not in CSV" do
        expect(described_class.for_state("FAKE")).to eq({})
      end
    end

    describe ".get" do
      let(:state) { all_counties.keys.first }
      let(:county) { all_counties[state].keys.first }

      it "returns the county when valid inputs are provided" do
        result = described_class.get(state, county)
        expect(result).to eq(all_counties[state][county])
      end

      it "raises error when state_code is blank" do
        expect {
          described_class.get(nil, county)
        }.to raise_error(ArgumentError, /state_code is required/)
      end

      it "raises error when county_key is blank" do
        expect {
          described_class.get(state, nil)
        }.to raise_error(ArgumentError, /county_key is required/)
      end

      it "raises error when county does not exist" do
        expect {
          described_class.get(state, "Fake County")
        }.to raise_error(StandardError, /County not found/)
      end
    end

  end

  describe LocationData::ZipCodes do
    let(:data_dir) { Rails.root.join("config/data/counties") }
    let(:all_zip_codes) { described_class::ALL_ZIP_CODES }

    before do
      skip "CSV files not found" unless Dir.exist?(data_dir)
    end

    it "loads CSV files for states that match offices to zip codes" do
      states = LocationData::States::STATES_INFO.select { |_, state_info| state_info[:office_by] == :zip_code }.keys
      expect(all_zip_codes.keys).to match_array(states)
    end

    describe "zip code counts" do
      it "reports correct number of offices per state" do
        all_zip_codes.each do |state, zips|
          csv_file = data_dir.join("#{state}.csv")
          expected_count = File.exist?(csv_file) ? CSV.read(csv_file, headers: true).count { |row| row[LocationData::ZipCodes::ZIP_CODE]&.strip.present? } : 0
          expect(zips.values.flatten.size).to eq(expected_count)
        end
      end
    end

    describe ".get_all" do
      let(:state) { all_zip_codes.keys.first }
      let(:zip_code) { all_zip_codes[state].keys.first }

      it "returns the array of offices for a valid state/zip" do
        result = described_class.get_all(state, zip_code)
        expect(result).to eq(all_zip_codes[state][zip_code])
      end

      it "returns multiple offices when the zip has more than one" do
        multi_zip = all_zip_codes[state].find { |_, offices| offices.size > 1 }&.first
        skip "No zip with multiple offices" unless multi_zip

        result = described_class.get_all(state, multi_zip)
        expect(result.size).to be > 1
      end

      it "raises ArgumentError when state is blank" do
        expect {
          described_class.get_all(nil, zip_code)
        }.to raise_error(ArgumentError, /state_code is required/)
      end

      it "raises ArgumentError when zip_code is blank" do
        expect {
          described_class.get_all(state, nil)
        }.to raise_error(ArgumentError, /zip_code is required/)
      end

      it "raises StandardError when zip code is not found" do
        expect {
          described_class.get_all(state, "00000")
        }.to raise_error(StandardError, /Zip code not found/)
      end
    end
  end
end

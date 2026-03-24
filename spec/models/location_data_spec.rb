require "rails_helper"
require "csv"

RSpec.describe LocationData do
  describe LocationData::States do
    describe ".options" do
      it "returns state options including translated not listed" do
        allow(I18n).to receive(:t).with("views.location.edit.not_listed").and_return("Not listed")

        options = described_class.options

        expect(options).to include(["North Carolina", "NC"])
        expect(options).to include(["Not listed", "NOT_LISTED"])
      end
    end

    describe "VALID_VALUES" do
      it "includes all valid state values" do
        expect(described_class::VALID_VALUES).to contain_exactly("NC", "NOT_LISTED")
      end
    end
  end

  describe LocationData::Counties do
    let(:data_dir) { Rails.root.join("config/data/counties") }
    let(:all_counties) { described_class::ALL_COUNTIES }

    before do
      skip "County CSV files not found" unless Dir.exist?(data_dir)
    end

    it "loads all CSV files for states" do
      csv_files = Dir.glob(data_dir.join("*.csv")).map { |f| File.basename(f, ".csv") }
      expect(all_counties.keys).to match_array(csv_files)
    end

    describe ".for_state" do
      it "returns all counties from CSV for each state" do
        all_counties.each do |state, counties|
          # Check that each county has a name
          expect(counties.keys).to all(satisfy { |k| k.is_a?(String) && !k.empty? })
        end
      end

      it "returns empty hash for a state not in CSV" do
        expect(described_class.for_state("FAKE")).to eq({})
      end
    end

    describe ".options_for" do
      it "returns county options matching CSV data" do
        all_counties.each do |state, counties|
          options = described_class.options_for(state)
          expect(options.size).to eq(counties.size)

          counties.keys.each do |county_name|
            expect(options).to include([county_name, county_name])
          end
        end
      end

      it "returns empty array for unknown state" do
        expect(described_class.options_for("FAKE")).to eq([])
      end
    end

    describe ".get" do
      it "returns the correct data for each county" do
        all_counties.each do |state, counties|
          counties.each do |county_name, data|
            result = described_class.get(state, county_name)
            expect(result).to eq(data)
          end
        end
      end

      it "returns nil for unknown county or state" do
        expect(described_class.get("NC", "Fake County")).to be_nil
        expect(described_class.get("FAKE", "Some County")).to be_nil
      end
    end

    describe "county counts" do
      it "reports correct number of counties per state" do
        all_counties.each do |state, counties|
          csv_file = data_dir.join("#{state}.csv")
          expected_count = File.exist?(csv_file) ? CSV.read(csv_file, headers: true).count { |row| row[LocationData::Counties::COUNTY_NAME]&.strip.present? } : 0
          expect(counties.size).to eq(expected_count)
        end
      end
    end

    describe ".fetch_county!" do
      let(:state) { all_counties.keys.first }
      let(:county) { all_counties[state].keys.first }

      it "returns the county when valid inputs are provided" do
        result = described_class.fetch_county!(state, county)
        expect(result).to eq(all_counties[state][county])
      end

      it "raises error when state_code is blank" do
        expect {
          described_class.fetch_county!(nil, county)
        }.to raise_error(ArgumentError, /state_code is required/)
      end

      it "raises error when county_key is blank" do
        expect {
          described_class.fetch_county!(state, nil)
        }.to raise_error(ArgumentError, /county_key is required/)
      end

      it "raises error when county does not exist" do
        expect {
          described_class.fetch_county!(state, "Fake County")
        }.to raise_error(StandardError, /County not found/)
      end
    end

    describe ".website_for" do
      let(:state) { all_counties.keys.first }
      let(:county) { all_counties[state].keys.first }

      it "returns the website for a valid county" do
        expected = all_counties[state][county][:website]
        expect(described_class.website_for(state, county)).to eq(expected)
      end

      it "raises when county not found" do
        expect {
          described_class.website_for(state, "Fake County")
        }.to raise_error(StandardError)
      end
    end

    describe ".upload_portal_or_email_for" do
      let(:state) { all_counties.keys.first }

      it "returns upload value when present" do
        county_name, data = all_counties[state].find { |_, d| d[:upload_portal_or_email].present? }
        skip "No county with upload present" unless county_name

        result = described_class.upload_portal_or_email_for(state, county_name)
        expect(result).to eq(data[:upload_portal_or_email])
      end

      it "falls back to email when upload is blank" do
        county_name, data = all_counties[state].find { |_, d| d[:upload_portal_or_email].blank? && d[:email].present? }
        skip "No suitable county for fallback test" unless county_name

        result = described_class.upload_portal_or_email_for(state, county_name)
        expect(result).to eq(data[:email])
      end
    end

    describe ".mailing_address_for" do
      let(:state) { all_counties.keys.first }
      let(:county) { all_counties[state].keys.first }

      it "returns the mailing address" do
        expected = all_counties[state][county][:mailing_address]
        expect(described_class.mailing_address_for(state, county)).to eq(expected)
      end
    end

    describe ".physical_address_for" do
      let(:state) { all_counties.keys.first }

      it "returns physical address when present" do
        county_name, data = all_counties[state].find { |_, d| d[:physical_address].present? }
        skip "No county with physical address" unless county_name

        result = described_class.physical_address_for(state, county_name)
        expect(result).to eq(data[:physical_address])
      end

      it "falls back to mailing address when physical is blank" do
        county_name, data = all_counties[state].find { |_, d| d[:physical_address].blank? && d[:mailing_address].present? }
        skip "No suitable county for fallback test" unless county_name

        result = described_class.physical_address_for(state, county_name)
        expect(result).to eq(data[:mailing_address])
      end
    end

    describe ".phone_for" do
      let(:state) { all_counties.keys.first }
      let(:county) { all_counties[state].keys.first }

      it "returns the phone number" do
        expected = all_counties[state][county][:phone]
        expect(described_class.phone_for(state, county)).to eq(expected)
      end
    end
  end
end

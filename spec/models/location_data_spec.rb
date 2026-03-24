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
  end
end

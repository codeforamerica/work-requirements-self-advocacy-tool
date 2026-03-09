require "rails_helper"

RSpec.describe LocationData do
  describe LocationData::States do
    describe ".options" do
      it "returns state options including translated not listed" do
        allow(I18n).to receive(:t).with("views.location.edit.not_listed").and_return("Not listed")

        options = described_class.options

        expect(options).to include(["Delaware", "DE"])
        expect(options).to include(["North Carolina", "NC"])
        expect(options).to include(["Not listed", "NOT_LISTED"])
      end
    end

    describe "VALID_VALUES" do
      it "includes all valid state values" do
        expect(described_class::VALID_VALUES).to contain_exactly("DE", "NC", "NOT_LISTED")
      end
    end
  end

  describe LocationData::Counties do
    let(:mock_data) do
      {
        "NC" => {
          "Anson County" => {
            name: "Anson County",
            mailing_address: "123 Main",
            physical_address: "123 Main",
            phone: "111-111-1111",
            fax: nil,
            email: "office@example.com",
            website: "example.com",
            upload: "upload@example.com"
          },
          "Wake County" => {
            name: "Wake County"
          }
        }
      }
    end

    before do
      stub_const(
        "LocationData::Counties::ALL_COUNTIES",
        mock_data
      )
    end

    describe ".for_state" do
      it "returns counties for a state" do
        result = described_class.for_state("NC")

        expect(result.keys).to include("Anson County", "Wake County")
      end

      it "returns empty hash for unknown state" do
        expect(described_class.for_state("TX")).to eq({})
      end
    end

    describe ".options_for" do
      it "returns county select options" do
        options = described_class.options_for("NC")

        expect(options).to include(
                             ["Anson County", "Anson County"],
                             ["Wake County", "Wake County"]
                           )
      end

      it "returns empty array for state with no counties" do
        expect(described_class.options_for("TX")).to eq([])
      end
    end

    describe ".get" do
      it "returns a specific county's data" do
        county = described_class.get("NC", "Anson County")

        expect(county[:name]).to eq("Anson County")
        expect(county[:email]).to eq("office@example.com")
      end

      it "returns nil for unknown county" do
        expect(described_class.get("NC", "Fake County")).to be_nil
      end
    end
  end
end

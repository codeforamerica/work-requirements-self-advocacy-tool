require "rails_helper"

RSpec.describe DateHelper, type: :helper do
  describe "#parse_date_params" do
    it "returns a Date for valid year, month, day strings" do
      expect(helper.parse_date_params("1990", "7", "13")).to eq Date.new(1990, 7, 13)
    end

    it "returns nil if any value is blank" do
      expect(helper.parse_date_params("", "7", "13")).to be_nil
      expect(helper.parse_date_params("1990", nil, "13")).to be_nil
      expect(helper.parse_date_params("1990", "7", "")).to be_nil
    end

    it "returns nil for an invalid date" do
      expect(helper.parse_date_params("1990", "13", "1")).to be_nil
      expect(helper.parse_date_params("1990", "2", "30")).to be_nil
    end

    it "returns nil if any value is an Array (malformed request)" do
      expect(helper.parse_date_params(["1990", "2000"], "7", "13")).to be_nil
      expect(helper.parse_date_params("1990", ["7"], "13")).to be_nil
      expect(helper.parse_date_params("1990", "7", ["13"])).to be_nil
    end

    it "returns nil if any value is an ActionController::Parameters (malformed request)" do
      nested = ActionController::Parameters.new("foo" => "1990")
      expect(helper.parse_date_params(nested, "7", "13")).to be_nil
      expect(helper.parse_date_params("1990", nested, "13")).to be_nil
      expect(helper.parse_date_params("1990", "7", nested)).to be_nil
    end
  end
end

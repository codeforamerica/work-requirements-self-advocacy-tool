# app/models/location_data.rb
module LocationData
  module States
    DELAWARE = "DE"
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"

    OPTIONS = [
      ["Delaware", DELAWARE],
      ["North Carolina", NORTH_CAROLINA],
      ["It's not listed here", NOT_LISTED]
    ].freeze

    VALID_VALUES = [DELAWARE, NORTH_CAROLINA, NOT_LISTED].freeze
  end

  module Counties
    NORTH_CAROLINA = {
      "Alamance" => { name: "Alamance", phone: "336-570-6532" },
      "Alexander" => { name: "Alexander", phone: "828-632-1080" },
      "Alleghany" => { name: "Alleghany", phone: "336-372-2415" }
    }.freeze

    def self.for_state(state)
      case state
      when LocationData::States::NORTH_CAROLINA
        NORTH_CAROLINA
      else
        {}
      end
    end

    # Return array of [label, value] for select helpers
    def self.options_for(state)
      for_state(state).map { |key, data| [data[:name], key] }
    end

    def self.phone_for(state, county_key)
      for_state(state).dig(county_key, :phone)
    end
  end
end

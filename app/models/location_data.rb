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
      "wake" => {name: "Wake County", phone: "919-555-1111"},
      "mecklenburg" => {name: "Mecklenburg County", phone: "704-555-2222"}
    }.freeze

    def self.for_state(state)
      case state
      when States::NORTH_CAROLINA
        NORTH_CAROLINA
      else
        {}
      end
    end

    def self.options_for(state)
      for_state(state).map { |key, data| [data[:name], key] }
    end

    def self.phone_for(state, county_key)
      for_state(state).dig(county_key, :phone)
    end
  end
end

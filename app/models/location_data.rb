require "csv"

module LocationData
  module States
    DELAWARE = "DE"
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"

    VALID_VALUES = [DELAWARE, NORTH_CAROLINA, NOT_LISTED].freeze

    def self.options
      [
        ["Delaware", DELAWARE],
        ["North Carolina", NORTH_CAROLINA],
        [I18n.t("views.location.edit.not_listed"), NOT_LISTED]
      ]
    end

    def self.name_for(code)
      options.find { |name, value| value == code }&.first
    end
  end

  module Counties
    DATA_DIR = Rails.root.join("config/data/counties")

    FIELDS = {
      county_name: "County [COUNTY_AGENCY]",
      mailing_address: "Office mailing address [COUNTY_MAIL_ADDRESS]",
      physical_address: "Office Physical Address (if different) [COUNTY_PHYSICAL_ADDRESS]",
      phone: "Office phone number [COUNTY_PHONE]",
      fax: "Office fax number [COUNTY_FAX]",
      email: "Office email address [COUNTY_EMAIL_ADDRESS]",
      website: "Office Website [Link instead of spelling out URL] [COUNTY_WEBSITE]",
      upload_portal_or_email: "Upload portal or email [Link URLs, write out emails] [COUNTY_UPLOAD_EMAIL]",
      is_supported: "Is Supported?"
    }.freeze

    def self.load_all
      Dir.glob(DATA_DIR.join("*.csv")).each_with_object({}) do |file, states|
        state_code = File.basename(file, ".csv")
        counties = {}

        CSV.foreach(file, headers: true) do |row|
          county_name = row[FIELDS[:county_name]]&.strip
          next if county_name.blank?

          counties[county_name] = {
            name: county_name,
            mailing_address: row[FIELDS[:mailing_address]],
            physical_address: row[FIELDS[:physical_address]],
            phone: row[FIELDS[:phone]],
            fax: row[FIELDS[:fax]],
            email: row[FIELDS[:email]],
            website: row[FIELDS[:website]],
            upload_portal_or_email: row[FIELDS[:upload_portal_or_email]],
            is_supported: row[FIELDS[:is_supported]] == "Y"
          }
        end

        states[state_code] = counties.freeze
      end.freeze
    end

    ALL_COUNTIES = load_all

    # Core helper to fetch a county and raise if missing
    def self.fetch_county!(state_code, county_key)
      raise ArgumentError, "state_code is required" if state_code.blank?
      raise ArgumentError, "county_key is required" if county_key.blank?

      county = ALL_COUNTIES.dig(state_code, county_key)
      raise StandardError, "County not found for #{state_code} / #{county_key}" unless county

      county
    end

    # Public API
    def self.for_state(state)
      ALL_COUNTIES[state] || {}
    end

    def self.options_for(state)
      for_state(state).map { |_, data| [data[:name], _] }
    end

    def self.get(state, county_key)
      for_state(state)[county_key]
    end

    def self.website_for(state_code, county_key)
      fetch_county!(state_code, county_key)[:website]
    end

    def self.upload_portal_or_email_for(state_code, county_key)
      county = fetch_county!(state_code, county_key)
      county[:upload_portal_or_email].presence || county[:email]
    end

    def self.mailing_address_for(state_code, county_key)
      fetch_county!(state_code, county_key)[:mailing_address]
    end

    def self.physical_address_for(state_code, county_key)
      county = fetch_county!(state_code, county_key)
      county[:physical_address].presence || county[:mailing_address]
    end

    def self.phone_for(state_code, county_key)
      fetch_county!(state_code, county_key)[:phone]
    end
  end
end

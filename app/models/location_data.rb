require "csv"

module LocationData
  module States
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"

    VALID_VALUES = [NORTH_CAROLINA, NOT_LISTED].freeze

    def self.options
      [
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

    COUNTY_NAME = "County [COUNTY_AGENCY]"
    MAIL_ADDRESS = "Office mailing address [COUNTY_MAIL_ADDRESS]"
    PHYSICAL_ADDRESS = "Office Physical Address (if different) [COUNTY_PHYSICAL_ADDRESS]"
    PHONE = "Office phone number [COUNTY_PHONE]"
    FAX = "Office fax number [COUNTY_FAX]"
    EMAIL = "Office email address [COUNTY_EMAIL_ADDRESS]"
    WEBSITE = "Office Website [Link instead of spelling out URL] [COUNTY_WEBSITE]"
    UPLOAD = "Upload portal or email [Link URLs, write out emails] [COUNTY_UPLOAD_EMAIL]"
    IS_SUPPORTED = "Is Supported?"

    def self.load_all
      Dir.glob(DATA_DIR.join("*.csv")).each_with_object({}) do |file, states|
        state_code = File.basename(file, ".csv")

        counties = {}

        CSV.foreach(file, headers: true) do |row|
          county = row[COUNTY_NAME]&.strip
          next if county.blank?

          counties[county] = {
            name: county,
            mailing_address: row[MAIL_ADDRESS],
            physical_address: row[PHYSICAL_ADDRESS],
            phone: row[PHONE],
            fax: row[FAX],
            email: row[EMAIL],
            website: row[WEBSITE],
            upload: row[UPLOAD],
            is_supported: row[IS_SUPPORTED] == "Y"
          }
        end

        states[state_code] = counties.freeze
      end.freeze
    end

    ALL_COUNTIES = load_all

    def self.fetch_county!(state_code, county_key)
      raise ArgumentError, "state_code is required" if state_code.blank?
      raise ArgumentError, "county_key is required" if county_key.blank?

      county = ALL_COUNTIES.dig(state_code, county_key)
      raise StandardError, "County not found for #{state_code} / #{county_key}" unless county

      county
    end

    def self.for_state(state)
      ALL_COUNTIES[state] || {}
    end

    def self.options_for(state)
      for_state(state).map { |key, data| [data[:name], key] }
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

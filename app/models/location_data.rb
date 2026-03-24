require "csv"

module LocationData
  module States
    DELAWARE = "DE"
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"

    def self.options
      [
        ["Delaware", DELAWARE],
        ["North Carolina", NORTH_CAROLINA],
        [I18n.t("views.location.edit.not_listed"), NOT_LISTED]
      ]
    end

    VALID_VALUES = [DELAWARE, NORTH_CAROLINA, NOT_LISTED].freeze

    def self.state_website_for(state_code)
      "TODO WRITE STATE WEBSITE LOOKUP CODE"
    end

    def self.state_email_for(state_code)
      "TODO WRITE STATE EMAIL LOOKUP CODE"
    end

    def self.state_mailing_address_for(state_code)
      "TODO WRITE STATE MAILING ADDRESS LOOKUP CODE"
    end

    def self.state_physical_address_for(state_code)
      "TODO WRITE STATE PHYSICAL ADDRESS LOOKUP CODE"
    end

    def self.state_phone_for(state_code)
      "TODO WRITE STATE PHONE LOOKUP CODE"
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
      county = get(state_code, county_key)

      # 1. If county exists AND has a website, return it
      if county && county[:website].present?
        return county[:website]
      end

      # 2. Otherwise, try state-level fallback
      state_website = LocationData::States.state_website_for(state_code)
      return state_website if state_website.present?

      # 3. Nothing found
      nil
    end

    def self.email_for(state_code, county_key)
      county = get(state_code, county_key)

      # 1. If county exists AND has an email, return it
      if county && county[:email].present?
        return county[:email]
      end

      # 2. Otherwise, try state-level fallback
      state_email = LocationData::States.state_email_for(state_code)
      return state_email if state_email.present?

      # 3. Nothing found
      nil
    end

    def self.mailing_address_for(state_code, county_key)
      county = get(state_code, county_key)

      # 1. If county exists AND has a mailing address, return it
      if county && county[:mailing_address].present?
        return county[:mailing_address]
      end

      # 2. Otherwise, try state-level fallback
      state_mailing_address = LocationData::States.state_mailing_address_for(state_code)
      return state_mailing_address if state_mailing_address.present?

      # 3. Nothing found
      nil
    end

    def self.physical_address_for(state_code, county_key)
      county = get(state_code, county_key)

      # 1. If county exists AND has an physical address, return it
      if county && county[:physical_address].present?
        return county[:physical_address]
      end

      if county && county[:mailing_address].present?
        return county[:mailing_address]
      end

      # 2. Otherwise, try state-level fallback
      state_physical_address = LocationData::States.state_physical_address_for(state_code)
      return state_physical_address if state_physical_address.present?

      # 3. Nothing found
      nil
    end

    def self.phone_for(state_code, county_key)
      county = get(state_code, county_key)

      # 1. If county exists AND has a phone, return it
      if county && county[:phone].present?
        return county[:phone]
      end

      # 2. Otherwise, try state-level fallback
      state_phone = LocationData::States.state_phone_for(state_code)
      return state_phone if state_phone.present?

      # 3. Nothing found
      nil
    end
  end
end

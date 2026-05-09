require "csv"

module LocationData
  module States
    DELAWARE = "DE"
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"
    STATES_INFO = {
      NORTH_CAROLINA => {
        display_name: "North Carolina",
        pdf_filler_class: PdfFiller::NcPacketPdf,
        office_by: :county
      },
      DELAWARE => {
        display_name: "Delaware",
        pdf_filler_class: PdfFiller::PacketPdf,
        office_by: :zip
      }
    }

    class << self
      [:display_name, :pdf_filler_class].each do |attribute|
        define_method(attribute) do |state_code|
          unless STATES_INFO.key?(state_code)
            raise StandardError, "Invalid state code: #{state_code}"
          end

          STATES_INFO[state_code][attribute]
        end
      end
    end

    def self.active_states
      active_codes = (ENV["ACTIVE_STATES"] || "").split(",")
      STATES_INFO.slice(*active_codes)
    end

    def self.dropdown_options
      states_and_labels = active_states.map do |state_code, info|
        [info[:display_name], state_code]
      end
      states_and_labels << [I18n.t("views.location.edit.not_listed"), NOT_LISTED]
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
    UPLOAD_PORTAL_OR_EMAIL = "Upload portal or email [Link URLs, write out emails] [COUNTY_UPLOAD_EMAIL]"
    IS_SUPPORTED = "Is Supported?"

    def self.load_all
      Dir.glob(DATA_DIR.join("*.csv")).each_with_object({}) do |file, states|
        state_code = File.basename(file, ".csv")
        if States::STATES_INFO[state_code][:office_by] == :county
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
              upload_portal_or_email: row[UPLOAD_PORTAL_OR_EMAIL],
              is_supported: row[IS_SUPPORTED] == "Y"
            }
          end

          states[state_code] = counties.freeze
        end
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
      raise ArgumentError, "state_code is required" if state.blank?
      raise ArgumentError, "county_key is required" if county_key.blank?

      county = ALL_COUNTIES.dig(state, county_key)
      raise StandardError, "County not found for #{state} / #{county_key}" unless county

      county
    end

    def self.website_for(state_code, county_key)
      get(state_code, county_key)[:website]
    end

    def self.upload_portal_or_email_for(state_code, county_key)
      county = get(state_code, county_key)
      county[:upload_portal_or_email].presence || county[:email]
    end

    def self.email_for(state_code, county_key)
      get(state_code, county_key)[:email]
    end

    def self.mailing_address_for(state_code, county_key)
      get(state_code, county_key)[:mailing_address]
    end

    def self.physical_address_for(state_code, county_key)
      county = get(state_code, county_key)
      county[:physical_address].presence || county[:mailing_address]
    end

    def self.phone_for(state_code, county_key)
      get(state_code, county_key)[:phone]
    end
  end
end

require "csv"

module LocationData
  module States
    DELAWARE = "DE"
    NORTH_CAROLINA = "NC"
    NOT_LISTED = "NOT_LISTED"
    STATES_INFO = {
      DELAWARE => {
        display_name: "Delaware",
        pdf_filler_class: PdfFiller::PacketPdf,
        policy_class: StatePolicy::Delaware,
        office_by: :zip_code,
        survey_url: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_8rdcUjhPOWA0XzM"
      },
      NORTH_CAROLINA => {
        display_name: "North Carolina",
        pdf_filler_class: PdfFiller::NcPacketPdf,
        policy_class: StatePolicy::NorthCarolina,
        office_by: :county,
        survey_url: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3kgHxveKeorfFC6"
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
      states_and_labels = active_states.sort.map do |state_code, info|
        [info[:display_name], state_code]
      end
      states_and_labels << [I18n.t("views.location.edit.not_listed"), NOT_LISTED]
    end
  end

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

  module Counties
    # data structure looks like:
    # {
    #   STATE_CODE => {
    #     COUNTY_NAME => { ... OFFICE INFO ... }
    #   }
    # }
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

    def self.get(state, county_key)
      raise ArgumentError, "state_code is required" if state.blank?
      raise ArgumentError, "county_key is required" if county_key.blank?

      county = ALL_COUNTIES.dig(state, county_key)
      raise StandardError, "County not found for #{state} / #{county_key}" unless county

      county
    end
  end

  module ZipCodes
    ZIP_CODE = "ZIP Code [ZIP_CODE]"
    LAST_NAMES_A_SMH = "Last Names A-Smh [LN_A-Smh]"
    LAST_NAMES_SMI_Z = "Last Names Smi-Z [LN_Smi-Z]"
    SPECIAL_GEO = "Special Geo"
    SUBGEOGRAPHY = "Subgeography [SUBGEOGRAPHY]"

    # data structure looks like:
    # {
    #   STATE_CODE => {
    #     ZIP_CODE => [
    #       { ... OFFICE INFO ... }
    #     ],
    #   }
    # }
    def self.load_all
      Dir.glob(DATA_DIR.join("*.csv")).each_with_object({}) do |file, states|
        state_code = File.basename(file, ".csv")
        if States::STATES_INFO[state_code][:office_by] == :zip_code
          zip_codes = Hash.new { |hash, key| hash[key] = [] }

          CSV.foreach(file, headers: true) do |row|
            zip = row[ZIP_CODE]&.strip
            next if zip.blank?

            zip_codes[zip] << {
              name: row[COUNTY_NAME]&.strip,
              code: zip,
              mailing_address: row[MAIL_ADDRESS],
              physical_address: row[PHYSICAL_ADDRESS],
              phone: row[PHONE],
              fax: row[FAX],
              email: row[EMAIL],
              website: row[WEBSITE],
              upload_portal_or_email: row[UPLOAD_PORTAL_OR_EMAIL],
              is_supported: row[IS_SUPPORTED] == "Y",
              special_geo: row[SPECIAL_GEO] == "TRUE",
              last_names_a_smh: row[LAST_NAMES_A_SMH] == "TRUE",
              last_names_smi_z: row[LAST_NAMES_SMI_Z] == "TRUE",
              subgeography: row[SUBGEOGRAPHY]
            }
          end

          zip_codes.default_proc = nil
          states[state_code] = zip_codes.freeze
        end
      end.freeze
    end

    ALL_ZIP_CODES = load_all

    def self.for_state(state)
      ALL_ZIP_CODES[state] || {}
    end

    def self.get_all(state, zip_code)
      raise ArgumentError, "state_code is required" if state.blank?
      raise ArgumentError, "zip_code is required" if zip_code.blank?

      zips = ALL_ZIP_CODES.dig(state, zip_code)
      raise StandardError, "Zip code not found for #{state} / #{zip_code}" if zips.blank?

      zips
    end
  end
end

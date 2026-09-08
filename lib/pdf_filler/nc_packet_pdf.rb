module PdfFiller
  class NcPacketPdf < PacketPdf
    def initialize(screener)
      @nc_screener = screener.nc_screener
      super
    end

    def pdf_fields
      super.merge(
        homeschool_hours: @nc_screener.homeschool_hours.to_s,
        homeschool_name: @nc_screener.homeschool_name,
        operating_a_homeschool: @nc_screener.teaches_homeschool_yes?,
        operating_homeschool_30_or_more_hours: @nc_screener.operating_homeschool_30_or_more_hours?,
        at_least_55_no_diploma_not_working: @screener.state_policy.age_work_education_health_exemption?,
        preventing_work_domestic_violence: @screener.preventing_work_domestic_violence_yes?,
        preventing_work_drugs_alcohol: @screener.preventing_work_drugs_alcohol_yes?,
        preventing_work_place_to_sleep: @screener.preventing_work_place_to_sleep_yes?
      )
    end
  end
end

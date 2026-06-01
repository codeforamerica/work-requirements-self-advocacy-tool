module PdfFiller
  class NcPacketPdf < PacketPdf
    def initialize(screener)
      @nc_screener = screener.nc_screener
      super
    end

    def filled_pdf_source
      if @screener.has_exemption?
        "app/assets/pdfs/nc_packet--no-income.pdf"
      elsif @screener.has_earnings_exemption?
        "app/assets/pdfs/nc_packet.pdf"
      end
    end

    def hash_for_fillable_pdf
      super.merge(
        {
          homeschool_hours: @nc_screener.homeschool_hours.to_s,
          homeschool_name: @nc_screener.homeschool_name,
          operating_a_homeschool: @nc_screener.teaches_homeschool_yes?
        }
      )
    end

    def hash_for_generated_pdf
      super.merge(
        {
          operating_homeschool_30_or_more_hours: @nc_screener.operating_homeschool_30_or_more_hours?
        }
      )
    end

    private

    def shared_fields
      super.merge(
        at_least_55_no_diploma_not_working: @screener.nc_screener.age_work_education_health_exemption?,
        preventing_work_domestic_violence: @screener.preventing_work_domestic_violence_yes?,
        preventing_work_drugs_alcohol: @screener.preventing_work_drugs_alcohol_yes?,
        preventing_work_place_to_sleep: @screener.preventing_work_place_to_sleep_yes?,
      )
    end
  end
end

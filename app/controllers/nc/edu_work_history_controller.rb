module Nc
  class EduWorkHistoryController < QuestionController
    include WrExemptionsConcern

    def self.attributes_edited
      [
        :has_hs_diploma,
        :worked_last_five_years
      ]
    end

    def self.show?(screener)
      screener.state == LocationData::States::NORTH_CAROLINA && screener.age.to_i >= 55
    end

    def self.load_model(intake, item_index: nil)
      intake.nc_screener
    end
  end
end

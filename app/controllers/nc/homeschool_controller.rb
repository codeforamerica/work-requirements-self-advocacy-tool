module Nc
  class HomeschoolController < QuestionController
    include WrExemptionsConcern

    CHARACTER_LIMIT = 40

    def self.attributes_edited
      [
        :teaches_homeschool,
        :homeschool_name,
        :homeschool_hours
      ]
    end

    def self.show?(screener)
      screener.state == LocationData::States::NORTH_CAROLINA && super
    end

    def self.load_model(intake, item_index: nil)
      intake.nc_screener
    end
  end
end

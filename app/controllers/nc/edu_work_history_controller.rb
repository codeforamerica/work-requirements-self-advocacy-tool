module Nc
  class EduWorkHistoryController < QuestionController
    include WrExemptionsConcern

    before_action :redirect_unless_nc_screener_present

    def self.attributes_edited
      [
        :has_hs_diploma,
        :worked_last_five_years,
        :earned_more_than_threshold,
        :health_conditions_preventing_work
      ]
    end

    def self.show?(screener)
      screener.state == LocationData::States::NORTH_CAROLINA && screener.age.to_i >= 55 && super
    end

    def self.load_model(intake, item_index: nil)
      intake.nc_screener
    end

    private

    # Nc::HomeschoolController runs earlier in the flow and always creates
    # nc_screener first, so a missing one here means this page was reached
    # out of order rather than through normal navigation.
    def redirect_unless_nc_screener_present
      redirect_to root_path if current_screener.nc_screener.blank?
    end
  end
end

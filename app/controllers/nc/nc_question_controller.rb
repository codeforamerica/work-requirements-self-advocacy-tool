module Nc
  class NcQuestionController < QuestionController
    before_action :redirect_unless_nc_screener_present

    private

    # LocationController's after_update_success creates nc_screener via
    # state_policy.ensure_state_data! right after the state question, so a
    # missing one here means this page was reached out of order.
    def redirect_unless_nc_screener_present
      redirect_to root_path if current_screener.nc_screener.blank?
    end
  end
end

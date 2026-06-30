class LocationController < QuestionController
  def show_progress_bar
    false
  end

  def self.show?(screener)
    true
  end

  def edit
    @all_counties = LocationData::Counties::ALL_COUNTIES
    super
  end

  def self.attributes_edited
    [:state, :county, :zip_code]
  end

  private

  def after_update_success
    current_screener.state_policy.ensure_state_data!

    send_mixpanel_event(
      event_name: "page_submit",
      data: form_params(current_screener).compact_blank.to_h
    )
  end
end

require "rails_helper"

RSpec.describe SchoolEnrollmentMilestoneController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display
  end
end

require "rails_helper"

RSpec.describe ProofGuidanceController, type: :controller do
  describe "#display" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :display
  end

  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

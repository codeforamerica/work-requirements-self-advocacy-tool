require "rails_helper"

RSpec.describe ProofGuidanceController, type: :controller do
  describe ".show?" do
    it_behaves_like "show? with work rules exemption only"
  end
end

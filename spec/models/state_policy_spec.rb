require "rails_helper"

RSpec.describe StatePolicy do
  describe ".for" do
    it "resolves the policy class from STATES_INFO" do
      expect(StatePolicy.for(build(:screener, state: "NC"))).to be_a(StatePolicy::NorthCarolina)
      expect(StatePolicy.for(build(:screener, state: "DE"))).to be_a(StatePolicy::Delaware)
    end

    it "falls back to Base for a state with no policy_class" do
      expect(StatePolicy.for(Screener.new(state: "NOT_LISTED"))).to be_a(StatePolicy::Base)
    end
  end

  describe StatePolicy::NorthCarolina do
    let(:screener) { build(:screener, state: "NC") }

    it "does not require proof for the American Indian exemption" do
      screener.is_american_indian = "yes"
      expect(screener.state_policy.american_indian_exemption_requires_proof?).to be false
    end

    it "does not require proof of volunteering" do
      allow(screener).to receive(:volunteering?).and_return(true)
      expect(screener.state_policy.needs_proof_of_volunteering?).to be false
    end

    it "is exempt from state work rules when the nc_screener qualifies" do
      screener.build_nc_screener
      allow(screener.nc_screener).to receive(:exempt_from_work_rules?).and_return(true)
      expect(screener.state_policy.exempt_from_state_work_rules?).to be true
    end
  end

  describe StatePolicy::Base do
    let(:screener) { build(:screener, state: "DE") }

    it "requires proof for the American Indian exemption" do
      screener.is_american_indian = "yes"
      expect(screener.state_policy.american_indian_exemption_requires_proof?).to be true
    end

    it "requires proof of volunteering when volunteering" do
      allow(screener).to receive(:volunteering?).and_return(true)
      expect(screener.state_policy.needs_proof_of_volunteering?).to be true
    end

    it "is never exempt from state work rules" do
      expect(screener.state_policy.exempt_from_state_work_rules?).to be false
    end
  end
end

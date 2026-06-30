require "rails_helper"

RSpec.describe WorkRulesPolicy do
  describe ".for" do
    it "returns the policy class from STATES_INFO" do
      expect(WorkRulesPolicy.for(build(:screener, state: "NC"))).to be_a(WorkRulesPolicy::NorthCarolina)
      expect(WorkRulesPolicy.for(build(:screener, state: "DE"))).to be_a(WorkRulesPolicy::Delaware)
    end

    it "falls back to Base for a state with no policy_class" do
      expect(WorkRulesPolicy.for(Screener.new(state: "NOT_LISTED"))).to be_a(WorkRulesPolicy::Base)
    end
  end

  describe "Base (federal rules)" do
    let(:screener) { build(:screener, state: "DE") }
    let(:policy) { screener.state_policy }

    describe "#exempt_from_work_rules?" do
      it "is true when there is a general exemption" do
        allow(policy).to receive(:has_exemption?).and_return(true)
        allow(policy).to receive(:has_earnings_exemption?).and_return(false)
        expect(policy.exempt_from_work_rules?).to eq true
      end

      it "is true when there is an earnings exemption" do
        allow(policy).to receive(:has_exemption?).and_return(false)
        allow(policy).to receive(:has_earnings_exemption?).and_return(true)
        expect(policy.exempt_from_work_rules?).to eq true
      end

      it "is false when there is neither" do
        allow(policy).to receive(:has_exemption?).and_return(false)
        allow(policy).to receive(:has_earnings_exemption?).and_return(false)
        expect(policy.exempt_from_work_rules?).to eq false
      end
    end

    describe "#has_exemption?" do
      before { screener.birth_date = 30.years.ago.to_date }

      it "is true when age qualified (under 18)" do
        screener.birth_date = 16.years.ago.to_date
        expect(policy.has_exemption?).to eq true
      end

      it "is true when age qualified (65 or older)" do
        screener.birth_date = 70.years.ago.to_date
        expect(policy.has_exemption?).to eq true
      end

      it "is true when a non-working exemption attribute is yes" do
        screener.is_student = "yes"
        expect(policy.has_exemption?).to eq true
      end

      it "is false when there is a state-specific exemption" do
        allow(policy).to receive(:exempt_from_state_work_rules?).and_return(true)
        expect(policy.has_exemption?).to eq true
      end

      it "is false when no exemptions apply" do
        screener.assign_attributes(is_working: "no", is_student: "no")
        expect(policy.has_exemption?).to eq false
      end
    end

    describe "#has_earnings_exemption?" do
      it "is true when working 30 or more hours" do
        screener.assign_attributes(is_working: "yes", working_hours: 30)
        expect(policy.has_earnings_exemption?).to eq true
      end

      it "is true when earning at least 217.50 weekly" do
        screener.assign_attributes(is_working: "yes", working_weekly_earnings: 217.50)
        expect(policy.has_earnings_exemption?).to eq true
      end

      it "is false when working but under both thresholds" do
        screener.assign_attributes(is_working: "yes", working_hours: 10, working_weekly_earnings: 100)
        expect(policy.has_earnings_exemption?).to eq false
      end

      it "is false when not working" do
        screener.is_working = "no"
        expect(policy.has_earnings_exemption?).to eq false
      end
    end

    describe "#complies_with_work_rules?" do
      it "the total working, volunteering, and training is greater than or equal to 20" do
        allow(screener).to receive(:total_work_volunteer_and_training_hours).and_return(20)
        expect(policy.complies_with_work_rules?).to eq true
      end

      it "the total working, volunteering, and training is less than 20" do
        allow(screener).to receive(:total_work_volunteer_and_training_hours).and_return(19)
        expect(policy.complies_with_work_rules?).to eq false
      end
    end

    describe "#american_indian_exemption_requires_proof?" do
      it "is true when the applicant is American Indian and proof is required" do
        screener.is_american_indian = "yes"
        allow(policy).to receive(:requires_proof_of_american_indian_status?).and_return(true)
        expect(policy.american_indian_exemption_requires_proof?).to eq true
      end

      it "is false when proof is not required" do
        screener.is_american_indian = "yes"
        allow(policy).to receive(:requires_proof_of_american_indian_status?).and_return(false)
        expect(policy.american_indian_exemption_requires_proof?).to eq false
      end

      it "is false when the applicant is not American Indian" do
        screener.is_american_indian = "no"
        allow(policy).to receive(:requires_proof_of_american_indian_status?).and_return(true)
        expect(policy.american_indian_exemption_requires_proof?).to eq false
      end
    end

    describe "#needs_proof_of_volunteering?" do
      it "is true when volunteering? is true" do
        allow(screener).to receive(:volunteering?).and_return(true)
        expect(policy.needs_proof_of_volunteering?).to eq true
      end

      it "is false when volunteering? is false" do
        allow(screener).to receive(:volunteering?).and_return(false)
        expect(policy.needs_proof_of_volunteering?).to eq false
      end
    end

    it "exempt_from_state_work_rules? and extra_preventing_work? are false by default; creates no state-specific record by default" do
      expect(policy.exempt_from_state_work_rules?).to eq false
      expect(policy.extra_preventing_work?).to eq false
      expect(policy.ensure_state_data!).to be_nil
    end
  end

  describe WorkRulesPolicy::NorthCarolina do
    let(:screener) { build(:screener, state: "NC") }
    let(:policy) { screener.state_policy }

    it "does not require proof of American Indian status" do
      screener.is_american_indian = "yes"
      expect(policy.american_indian_exemption_requires_proof?).to eq false
    end

    it "does not require proof of volunteering" do
      allow(screener).to receive(:volunteering?).and_return(true)
      expect(policy.needs_proof_of_volunteering?).to eq false
    end

    describe "#exempt_from_state_work_rules?" do
      it "is true when the nc_screener is present and exempt" do
        screener.build_nc_screener
        allow(screener.nc_screener).to receive(:exempt_from_work_rules?).and_return(true)
        expect(policy.exempt_from_state_work_rules?).to eq true
      end

      it "is false when the nc_screener is present but not exempt" do
        screener.build_nc_screener
        allow(screener.nc_screener).to receive(:exempt_from_work_rules?).and_return(false)
        expect(policy.exempt_from_state_work_rules?).to eq false
      end

      it "is false when there is no nc_screener" do
        expect(policy.exempt_from_state_work_rules?).to eq false
      end
    end

    describe "#extra_preventing_work?" do
      it "is true when the nc_screener has the age/education/health exemption" do
        screener.build_nc_screener
        allow(screener.nc_screener).to receive(:age_work_education_health_exemption?).and_return(true)
        expect(policy.extra_preventing_work?).to eq true
      end

      it "is false when there is no nc_screener" do
        expect(policy.extra_preventing_work?).to eq false
      end
    end

    describe "#ensure_state_data!" do
      it "creates the nc_screener when missing" do
        screener.save!
        expect { policy.ensure_state_data! }.to change { screener.reload.nc_screener.present? }.from(false).to(true)
      end

      it "does not replace an existing nc_screener" do
        screener.save!
        screener.create_nc_screener
        expect { policy.ensure_state_data! }.not_to change { screener.reload.nc_screener.id }
      end
    end
  end

  describe WorkRulesPolicy::Delaware do
    let(:screener) { build(:screener, state: "DE") }
    let(:policy) { screener.state_policy }

    it "requires proof of American Indian status" do
      screener.is_american_indian = "yes"
      expect(policy.american_indian_exemption_requires_proof?).to eq true
    end
  end
end

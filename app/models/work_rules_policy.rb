# Resolved from LocationData::States::STATES_INFO[state][:policy_class]
module WorkRulesPolicy
  def self.for(screener)
    policy_class = LocationData::States::STATES_INFO.dig(screener.state, :policy_class) || Base
    policy_class.new(screener)
  end

  # Federal policy baseline
  class Base
    attr_reader :screener

    def initialize(screener)
      @screener = screener
    end

    def exempt_from_work_rules?
      has_exemption? || has_earnings_exemption?
    end

    def has_exemption?
      return true if screener.age_qualified?
      return true if exempt_from_state_work_rules?

      Screener::ELIGIBILITY_EXEMPTION_ATTRIBUTES.any? do |attribute|
        screener.public_send("#{attribute}_yes?")
      end
    end

    def has_earnings_exemption?
      screener.is_working_yes? &&
        (screener.working_30_or_more_hours? || screener.earnings_above_minimum?)
    end

    def complies_with_work_rules?
      screener.total_work_volunteer_and_training_hours >= 20
    end

    def american_indian_exemption_requires_proof?
      requires_proof_of_american_indian_status? && screener.is_american_indian_yes?
    end

    def needs_proof_of_volunteering?
      requires_proof_of_volunteering? && screener.volunteering?
    end

    def exempt_from_state_work_rules?
      false
    end

    def extra_preventing_work?
      false
    end

    # Create any per-state supplemental record this state needs (called after_update_success
    # on location controller)
    def ensure_state_data!
      nil
    end

    def requires_proof_of_american_indian_status?
      true
    end

    def requires_proof_of_volunteering?
      true
    end
  end

  class NorthCarolina < Base
    def exempt_from_state_work_rules?
      nc_screener.present? && nc_screener.exempt_from_work_rules?
    end

    def extra_preventing_work?
      nc_screener.present? && nc_screener.age_work_education_health_exemption?
    end

    def ensure_state_data!
      screener.create_nc_screener if nc_screener.nil?
    end

    def requires_proof_of_american_indian_status?
      false
    end

    def requires_proof_of_volunteering?
      false
    end

    private

    def nc_screener
      screener.nc_screener
    end
  end

  class Delaware < Base
  end
end

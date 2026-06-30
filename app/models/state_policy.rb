# Per-state policy for work-rule decisions that vary by state.
#
# Resolved from LocationData::States::STATES_INFO[state][:policy_class]; any state
# without an entry (including NOT_LISTED) falls back to Base. Adding a state's
# rule differences means adding one subclass here instead of editing scattered
# `case state when NORTH_CAROLINA` branches in Screener.
module StatePolicy
  def self.for(screener)
    klass = LocationData::States::STATES_INFO.dig(screener.state, :policy_class) || Base
    klass.new(screener)
  end

  class Base
    attr_reader :screener

    def initialize(screener)
      @screener = screener
    end

    def exempt_from_state_work_rules?
      false
    end

    def american_indian_exemption_requires_proof?
      screener.is_american_indian_yes?
    end

    def needs_proof_of_volunteering?
      screener.volunteering?
    end

    # Whether this state has additional exemption circumstances (beyond the
    # shared PREVENTING_WORK_ATTRIBUTES) that count as "preventing work".
    def extra_preventing_work?
      false
    end
  end

  class NorthCarolina < Base
    def exempt_from_state_work_rules?
      screener.nc_screener.present? && screener.nc_screener.exempt_from_work_rules?
    end

    def american_indian_exemption_requires_proof?
      false
    end

    def needs_proof_of_volunteering?
      false
    end

    def extra_preventing_work?
      screener.nc_screener.present? && screener.nc_screener.age_work_education_health_exemption?
    end
  end

  # Delaware uses all of the Base defaults today; the class exists so STATES_INFO
  # can point at it and so DE-specific rules have an obvious home later.
  class Delaware < Base
  end
end

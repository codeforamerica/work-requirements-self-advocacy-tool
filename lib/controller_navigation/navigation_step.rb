module ControllerNavigation
  class NavigationStep
    attr_accessor :increment_step
    # Indicates whether this step contributes to the overall count (Cancel / Failure steps typically don't)
    alias_method :increment_step?, :increment_step

    def initialize(controller, increment_step = true)
      @controller = controller
      @increment_step = increment_step
    end

    def controllers
      [@controller]
    end

    def pages(intake)
      [{controller: @controller}]
    end
  end
end

module Navigation
  class ScreenerNavigation < ControllerNavigation::ControllerNavigation
    SECTIONS = [
      ControllerNavigation::NavigationSection.new("navigation.section_1", [
        ControllerNavigation::NavigationStep.new(OverviewController),
        ControllerNavigation::NavigationStep.new(LanguagePreferenceController),
        ControllerNavigation::NavigationStep.new(ReceivingBenefitsController),
        ControllerNavigation::NavigationStep.new(AmericanIndianController),
        ControllerNavigation::NavigationStep.new(HasChildController),
        ControllerNavigation::NavigationStep.new(CaringForSomeoneController),
        ControllerNavigation::NavigationStep.new(HasUnemploymentBenefitsController),
        ControllerNavigation::NavigationStep.new(DisabilityBenefitsController),
        ControllerNavigation::NavigationStep.new(BasicInfoMilestoneController),
        ControllerNavigation::NavigationStep.new(PersonalInformationController),
        ControllerNavigation::NavigationStep.new(TempEndController)
      ])
    ].freeze
  end
end

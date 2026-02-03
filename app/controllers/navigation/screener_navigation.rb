module Navigation
  class ScreenerNavigation < ControllerNavigation::ControllerNavigation
    SECTIONS = [
      ControllerNavigation::NavigationSection.new("navigation.section_1", [
        ControllerNavigation::NavigationStep.new(OverviewController),
        ControllerNavigation::NavigationStep.new(BirthDateController),
        ControllerNavigation::NavigationStep.new(ReceivingBenefitsController),
        ControllerNavigation::NavigationStep.new(AmericanIndianController),
        ControllerNavigation::NavigationStep.new(HasChildController),
        ControllerNavigation::NavigationStep.new(CaringForSomeoneController),
        ControllerNavigation::NavigationStep.new(IsPregnantController),
        ControllerNavigation::NavigationStep.new(HasUnemploymentBenefitsController),
        ControllerNavigation::NavigationStep.new(DisabilityBenefitsController),
        ControllerNavigation::NavigationStep.new(WorkingController),
        ControllerNavigation::NavigationStep.new(MigrantFarmworkerController),
        ControllerNavigation::NavigationStep.new(CommunityServiceController),
        ControllerNavigation::NavigationStep.new(WorkTrainingController),
        ControllerNavigation::NavigationStep.new(IsStudentController),
        ControllerNavigation::NavigationStep.new(PersonalSituationsMilestoneController),
        ControllerNavigation::NavigationStep.new(PreventingWorkController),
        ControllerNavigation::NavigationStep.new(BasicInfoMilestoneController),
        ControllerNavigation::NavigationStep.new(PersonalInformationController),
        ControllerNavigation::NavigationStep.new(EmailController),
        ControllerNavigation::NavigationStep.new(EmailNudgeController),
        ControllerNavigation::NavigationStep.new(TempEndController)
      ])
    ].freeze
  end
end

module Navigation
  class ScreenerNavigation < ControllerNavigation::ControllerNavigation
    SECTIONS = [
      ControllerNavigation::NavigationStep.new(DateOfBirthController),
      ControllerNavigation::NavigationStep.new(TribeOrNationController),
      ControllerNavigation::NavigationStep.new(LivingWithSomeoneController),
      ControllerNavigation::NavigationStep.new(CaringForSomeoneController),
      ControllerNavigation::NavigationStep.new(PregnancyController),
      ControllerNavigation::NavigationStep.new(UnemploymentController),
      ControllerNavigation::NavigationStep.new(DisabilityBenefitsController),
      ControllerNavigation::NavigationStep.new(EmploymentController),
      ControllerNavigation::NavigationStep.new(MigrantFarmworkerController),
      ControllerNavigation::NavigationStep.new(CommunityServiceController),
      ControllerNavigation::NavigationStep.new(TrainingProgramController),
      ControllerNavigation::NavigationStep.new(SchoolEnrollmentController),
      ControllerNavigation::NavigationStep.new(AlcoholTreatmentProgramController),
      ControllerNavigation::NavigationStep.new(PreventingWorkMilestoneController),
      ControllerNavigation::NavigationStep.new(PreventingWorkSituationsController),
      ControllerNavigation::NavigationStep.new(PreventingWorkDetailsController),
      ControllerNavigation::NavigationStep.new(BasicInfoMilestoneController),
      ControllerNavigation::NavigationStep.new(PersonalInformationController),
      ControllerNavigation::NavigationStep.new(BasicInfoEmailController),
      ControllerNavigation::NavigationStep.new(BasicInfoEmailNudgeController),
      ControllerNavigation::NavigationStep.new(NewResponseController)
    ].freeze
  end
end

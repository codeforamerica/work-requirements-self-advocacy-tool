module Navigation
  class ScreenerNavigation < ControllerNavigation::ControllerNavigation
    SECTIONS = [
      ControllerNavigation::NavigationSection.new("navigation.section_1", [
        ControllerNavigation::NavigationStep.new(LanguagePreferenceController),
        ControllerNavigation::NavigationStep.new(TempEndController),
      ]),
    ].freeze
  end
end
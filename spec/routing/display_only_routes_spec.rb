require "rails_helper"

RSpec.describe "display-only page routing", type: :routing do
  all_controllers = Navigation::ScreenerNavigation.controllers.uniq
  display_only = all_controllers.reject(&:accepts_update?)
  accepts_update = all_controllers.select(&:accepts_update?)

  describe "display-only controllers" do
    display_only.each do |controller|
      it "does not route PUT to #{controller.name}" do
        expect(put("/#{controller.to_param}")).not_to be_routable
      end
    end
  end

  describe "form controllers that accept user input" do
    accepts_update.each do |controller|
      it "routes PUT to #{controller.name}" do
        expect(put("/#{controller.to_param}")).to be_routable
      end
    end
  end
end

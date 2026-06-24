require "rails_helper"

RSpec.describe "display-only page routing", type: :routing do
  describe "display-only controllers" do
    it "do not respond to PUT (no update route registered)" do
      expect(put("/proof-guidance")).not_to be_routable
      expect(put("/wages-hours-milestone")).not_to be_routable
      expect(put("/work-rules-apply-met")).not_to be_routable
      expect(put("/work-rules-apply-unmet")).not_to be_routable
      expect(put("/basic-info-milestone")).not_to be_routable
      expect(put("/out-of-state")).not_to be_routable
      expect(put("/preventing-work-milestone")).not_to be_routable
      expect(put("/age-exemption")).not_to be_routable
      expect(put("/new-response")).not_to be_routable
    end
  end

  describe "form controllers" do
    it "respond to PUT (update route is registered)" do
      expect(put("/tribe-or-nation")).to be_routable
      expect(put("/date-of-birth")).to be_routable
      expect(put("/pregnancy")).to be_routable
      expect(put("/basic-info-details")).to be_routable
      expect(put("/location")).to be_routable
    end
  end
end

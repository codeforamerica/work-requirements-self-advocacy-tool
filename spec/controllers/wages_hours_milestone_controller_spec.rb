require "rails_helper"

RSpec.describe WagesHoursMilestoneController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
  end

  describe ".show?" do
    it_behaves_like "show? when screener has no exemption"
  end
end

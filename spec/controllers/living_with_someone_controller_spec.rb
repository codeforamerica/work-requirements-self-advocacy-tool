require "rails_helper"

RSpec.describe LivingWithSomeoneController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
    it_behaves_like "rejects invalid enum values", fields: [:has_child]
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end
end

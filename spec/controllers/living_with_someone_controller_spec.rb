require "rails_helper"

RSpec.describe LivingWithSomeoneController, type: :controller do
  describe "#edit" do
    it_behaves_like :session_must_be_active_for_this_get_action, action: :edit
  end

  describe "#update" do
    it_behaves_like :session_must_be_active_for_this_post_action, action: :edit
    it_behaves_like :session_must_be_active_for_this_post_action, action: :update
    it_behaves_like "rejects invalid enum values", fields: [:has_child]
    let(:params) { {has_child: "yes"} }

    it_behaves_like "a controller where update fires a page_submit Mixpanel event" do
      let(:page_submit_cases) do
        [{
          form_params: params,
          expected_data: params
        }]
      end
      let(:invalid_params) { {has_child: ""} }
    end

    it "persists the values to the current screener" do
      screener = create(:screener)
      sign_in screener

      post :update, params: {screener: params}
      screener.reload
      expect(screener.has_child).to eq "yes"
    end
  end

  describe ".show?" do
    it_behaves_like "a show method that considers age exemption"
  end
end

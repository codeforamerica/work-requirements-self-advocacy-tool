RSpec.shared_examples "a controller where update fires a page_submit Mixpanel event" do |nc_screener = false|
  let(:screener) { nc_screener ? create(:screener, :with_nc_screener) : create(:screener) }
  let(:param_key) { nc_screener ? :nc_screener : :screener }
  # Including specs that want the invalid-form case define `invalid_params`.
  # Leave it undefined (defaults to nil) for forms that have no invalid case.
  let(:invalid_params) { nil }

  before do
    sign_in screener
  end

  context "when the form is valid" do
    it "fires a page_submit event with non-PII field values and PII field values replaced with has_<field> (true/false)" do
      submitted_data = []
      allow(MixpanelService).to receive(:send_event) do |event_name:, data:, **|
        submitted_data << data if event_name == "page_submit"
      end

      page_submit_cases.each do |kase|
        post :update, params: {param_key => kase[:form_params]}
      end

      expect(submitted_data).to eq(page_submit_cases.map { |kase| kase[:expected_data] })
    end
  end

  context "when the form is invalid" do
    it "does not fire a page_submit event" do
      skip "no invalid_params defined for this form" if invalid_params.nil?

      allow(MixpanelService).to receive(:send_event)

      post :update, params: {param_key => invalid_params}

      expect(MixpanelService).not_to have_received(:send_event).with(
        hash_including(event_name: "page_submit")
      )
    end
  end
end

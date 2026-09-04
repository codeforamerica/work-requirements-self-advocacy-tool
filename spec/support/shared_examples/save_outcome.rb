RSpec.shared_examples "saves outcome on page visit" do |expected_outcome:|
  # Default screener; override with a `let(:screener)` block when the page under
  # test only shows for a specific kind of screener.
  let(:screener) { create(:screener) }

  context "with signed in screener" do
    before { sign_in screener }

    context "on first visit" do
      it "sets outcome and outcome_arrived_at" do
        get :display
        screener.reload
        expect(screener.outcome).to eq(expected_outcome)
        expect(screener.outcome_arrived_at).to be_present
      end
    end

    context "when outcome_arrived_at is already set and outcome is unchanged" do
      let(:original_time) { 1.hour.ago }

      before { screener.update!(outcome: expected_outcome, outcome_arrived_at: original_time) }

      it "does not update outcome_arrived_at" do
        get :display
        screener.reload
        expect(screener.outcome_arrived_at).to be_within(1.second).of(original_time)
      end
    end

    context "when outcome_arrived_at is already set but the outcome is changing" do
      let(:original_time) { 1.hour.ago }

      before { screener.update!(outcome: "different_outcome", outcome_arrived_at: original_time) }

      it "updates outcome and outcome_arrived_at" do
        get :display
        screener.reload
        expect(screener.outcome).to eq(expected_outcome)
        expect(screener.outcome_arrived_at).to be_within(1.second).of(Time.current)
      end
    end
  end
end

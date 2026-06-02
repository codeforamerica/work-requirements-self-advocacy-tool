RSpec.shared_examples "saves outcome on edit" do |expected_outcome:|
  describe "#edit" do
    context "with signed in screener" do
      let(:screener) { create(:screener) }

      before { sign_in screener }

      it "updates outcome and outcome_arrived_at" do
        get :edit
        screener.reload
        expect(screener.outcome).to eq(expected_outcome)
        expect(screener.outcome_arrived_at).to be_present
      end
    end
  end
end

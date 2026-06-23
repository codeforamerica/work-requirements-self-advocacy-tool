RSpec.shared_examples "rejects invalid enum values" do |fields:|
  fields.each do |field|
    context "with invalid value for #{field}" do
      it "returns 422 unprocessable content and does not raise" do
        screener = create(:screener)
        sign_in screener

        post :update, params: {screener: {field => "invalid_enum_value"}}

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

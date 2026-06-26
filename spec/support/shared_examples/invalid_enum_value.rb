RSpec.shared_examples "rejects invalid enum values" do |fields:, params_key: :screener, screener_factory: -> { create(:screener) }|
  fields.each do |field|
    context "with invalid value for #{field}" do
      it "returns 422 unprocessable content and does not raise" do
        screener = instance_exec(&screener_factory)
        sign_in screener

        post :update, params: {params_key => {field => "invalid_enum_value"}}

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end

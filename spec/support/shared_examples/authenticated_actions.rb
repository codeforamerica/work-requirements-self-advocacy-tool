# Usage:
#   it_behaves_like :session_must_be_active_for_this_get_action, action: :new
#
#   # set params for this spec
#   it_behaves_like :session_must_be_active_for_this_get_action, action: :new do
#     let(:params) do
#       { my_mode: { name: "some name" } }
#     end
#   end
#
#   # set values for this & other specs
#   let(:params) do
#     { my_mode: { name: "some name" } }
#   end
#
#   it_behaves_like :session_must_be_active_for_this_get_action, action: :new
#
shared_examples :session_must_be_active_for_this_get_action do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "without current screener" do
    it "redirects to the home page" do
      get action, params: params

      expect(response).to redirect_to root_path
    end
  end
end

shared_examples :session_must_be_active_for_this_post_action do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "without current screener" do
    it "redirects to the home page" do
      post action, params: params

      expect(response).to redirect_to root_path
    end
  end
end

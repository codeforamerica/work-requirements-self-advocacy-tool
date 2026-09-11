# Verifies the `ensure_page_navigable` before_action (registered on QuestionController)
# redirects to root when `.show?` returns false for the signed-in screener.
shared_examples "ensure_page_navigable redirects to root" do |action:, http_method: :get|
  it "redirects to root" do
    sign_in screener

    public_send(http_method, action)

    expect(response).to redirect_to(root_path)
  end
end

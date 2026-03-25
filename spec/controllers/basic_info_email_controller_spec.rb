require "rails_helper"

RSpec.describe BasicInfoEmailController, type: :controller do
  let(:screener) { create(:screener) }
  before { sign_in screener }

  describe "#update" do
    context "when email has extra spaces or capitalization" do
      it "saves the normalized lowercase email" do
        params = {
          email: "anisHa@codeforamerica.org ",
          email_confirmation: " anisha@codeforamerica.org"
        }

        post :update, params: {screener: params}
        expect(response).to redirect_to(subject.next_path)
        expect(screener.reload.email).to eq "anisha@codeforamerica.org"
      end
    end

    context "when email is invalid" do
      it "does not save and renders the form with errors" do
        params = {
          email: "invalid-email",
          email_confirmation: "invalid-email"
        }

        post :update, params: {screener: params}
        expect(response).to render_template(:edit)

        expect(assigns(:model).errors[:email]).to include("is invalid")
      end
    end

    context "when email and confirmation do not match" do
      it "does not save and renders the form with errors" do
        params = {
          email: "test@example.com",
          email_confirmation: "different@example.com"
        }

        post :update, params: {screener: params}
        expect(response).to render_template(:edit)
        expect(assigns(:model).errors[:email_confirmation]).to include("doesn't match Email")
      end
    end

    context "when from_download_form param is present" do
      it "requires email presence" do
        post :update, params: {screener: {email: "", email_confirmation: ""}, from_download_form: "true"}

        expect(response).to render_template(:edit)
        expect(assigns(:model).errors[:email]).to include("can't be blank")
      end
    end

    context "when return_to_review param is present" do
      it "preserves the param for the controller flow" do
        post :update,
          params: {
            screener: {email: "test@example.com", email_confirmation: "test@example.com"},
            return_to_review: "y"
          }

        expect(response).to redirect_to(subject.next_path)
      end
    end

    context "when no changes are made" do
      it "keeps the existing email intact" do
        screener.update!(email: "existing@example.com")
        post :update, params: {screener: {email: "", email_confirmation: ""}, from_download_form: "true"}

        expect(screener.reload.email).to eq "existing@example.com"
      end
    end
  end

  it "adds the confirmation code" do
    expect(screener.confirmation_code).to be_nil

    post :update, params: {screener: {email: "boop@example.com ", email_confirmation: "boop@example.com"}}

    expect(screener.reload.confirmation_code).to be_present
  end
end
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up" do
    context "as a guest" do
      it "renders a successful response" do
        get new_user_registration_path
        expect(response).to be_successful
      end
    end

    context "as an authenticated user" do
      let(:authenticated_user) { create(:user) }

      before do
        sign_in(authenticated_user)
      end

      it "directs to the dashboard with a warning" do
        get new_user_registration_path
        expect(response).to redirect_to(root_url)

        follow_redirect!
        expect(response.body).to have_selector(".alert-alert", text: t("devise.failure.already_authenticated"))
      end
    end
  end

  describe "POST /users" do
    context "with valid create user params" do
      let(:valid_password) { Faker::Internet.password }
      let(:valid_registration_params) do
        {
          user: {
            email: Faker::Internet.email,
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "redirects to the dashboard with a notice" do
        post user_registration_path, params: valid_registration_params
        expect(response).to redirect_to(root_url)

        follow_redirect!
        expect(response.body).to have_selector(".alert-notice", text: t("devise.registrations.signed_up"))
      end

      it "does not allow authenticated users" do
        sign_in create(:user)

        post user_registration_path, params: valid_registration_params
        expect(response).to redirect_to(root_url)

        follow_redirect!
        expect(response.body).to have_selector(".alert-alert", text: t("devise.failure.already_authenticated"))
      end
    end

    context "with mismatching passwords" do
      let(:invalid_registration_params) do
        {
          user: {
            email: Faker::Internet.email,
            password: Faker::Internet.password,
            password_confirmation: Faker::Lorem.words(number: 3).join
          }
        }
      end

      it "renders the form with an error" do
        post user_registration_path, params: invalid_registration_params
        expect(response).to be_successful

        expect(response.body).to have_content("Password confirmation doesn't match Password")
      end
    end

    context "with an email address matching an existing user" do
      let(:existing_user) { create(:user) }
      let(:valid_password) { Faker::Internet.password }
      let(:existing_registration_params) do
        {
          user: {
            email: existing_user.email,
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "renders the form with an error" do
        post user_registration_path, params: existing_registration_params
        expect(response).to be_successful

        expect(response.body).to have_content("Email has already been taken")
      end
    end
  end
end
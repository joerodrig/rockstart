# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Passwords", type: :request do
  describe "GET /users/sign_in" do
    context "as a guest" do
      it "renders a successful response" do
        get new_user_session_path
        expect(response).to be_successful
      end
    end

    context "as an authenticated user" do
      let(:authenticated_user) { create(:user) }

      before do
        sign_in authenticated_user
      end

      it "redirects back to the landing page" do
        get new_user_session_path
        expect(response).to redirect_to(root_url)
      end
    end

    context "with a soft deleted user" do
      let(:soft_deleted_user) { create(:user, :soft_deleted) }

      before do
        sign_in soft_deleted_user
      end

      it "redirects back to the landing page" do
        get new_user_session_path
        expect(response).to redirect_to(new_user_session_path)

        follow_redirect!
        expect(response.body).to have_selector(".alert-alert", text: t("devise.failure.deleted_account"))
      end
    end
  end

  describe "POST /users/sign_in", :cache_testing do
    context "with known user credentials" do
      let(:valid_password) { Faker::Internet.password }
      let(:known_user) { create(:user, password: valid_password) }

      let(:valid_sign_in_params) do
        {
          user: {
            email: known_user.email,
            password: valid_password
          }
        }
      end

      it "redirects to the dashboard" do
        post new_user_session_path, params: valid_sign_in_params
        expect(response).to redirect_to(root_url)

        follow_redirect!
        expect(controller.current_user).to eq known_user.reload
        expect(response.body).to have_selector(".alert-notice", text: t("devise.sessions.signed_in"))
      end
    end

    context "with known user credentials" do
      let(:known_user) { create(:user) }

      let(:invalid_sign_in_params) do
        {
          user: {
            email: known_user.email,
            password: Faker::Internet.password
          }
        }
      end

      it "renders the sign in form with an error" do
        post new_user_session_path, params: invalid_sign_in_params
        expect(response).to be_successful

        expect(response.body).to have_selector(".alert-alert", text: t("devise.failure.invalid", authentication_keys: "Email"))
      end
    end

    context "with unknown user credentials" do
      let(:unknown_sign_in_params) do
        {
          user: {
            email: Faker::Internet.email,
            password: Faker::Internet.password
          }
        }
      end

      it "renders the sign in form with an error" do
        post new_user_session_path, params: unknown_sign_in_params
        expect(response).to be_successful

        expect(response.body).to have_selector(".alert-alert", text: t("devise.failure.invalid", authentication_keys: "Email"))
      end
    end

    it "rate limits requests based off ip address" do
      5.times do
        post new_user_session_path, params: {
          user: {
            email: Faker::Internet.email,
            password: Faker::Internet.password
          }
        }
      end

      post new_user_session_path, params: {
        user: {
          email: Faker::Internet.email,
          password: Faker::Internet.password
        }
      }
      expect(response).to have_http_status(:too_many_requests)
    end

    it "rate limits requests based off email address" do
      valid_email_parameters = {
        user: {
          email: Faker::Internet.email,
          password: Faker::Internet.password
        }
      }

      5.times do |n|
        post new_user_session_path, params: valid_email_parameters, headers: {
          "REMOTE_ADDR" => format("120.0.1.%<n>d", n: n)
        }
      end

      post new_user_session_path, params: valid_email_parameters
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "DELETE /users/sign_outs" do
    context "with an authenticated user" do
      let(:authenticated_user) { create(:user) }

      before do
        sign_in(authenticated_user)
      end

      it "redirects to the login page with a notice" do
        delete destroy_user_session_path
        expect(response).to redirect_to(new_user_session_path)

        follow_redirect!
        expect(response.body).to have_selector(".alert-notice", text: t("devise.sessions.signed_out"))
      end
    end

    context "with a guest" do
      it "redirects to the landing page" do
        delete destroy_user_session_path
        expect(response).to redirect_to(new_user_session_path)

        follow_redirect!
        expect(response.body).to have_selector(".alert-notice", text: t("devise.sessions.signed_out"))
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "POST /auth/forgot_password" do
    let(:user) { create(:user, email: "test@example.com") }

    it "sends password reset email for existing user" do
      expect {
        post "/auth/forgot_password", params: { email: user.email }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(json_response["message"]).to include("Password reset instructions")
    end

    it "returns not found for non-existent user" do
      post "/auth/forgot_password", params: { email: "nonexistent@example.com" }

      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq(I18n.t("auth.errors.user_not_found"))
    end
  end

  describe "POST /auth/reset_password" do
    let(:user) { create(:user, email: "test@example.com", password: "old_password", password_confirmation: "old_password") }

    let!(:verification_token) do
      token = user.verification_tokens.create(token_type: :password_reset)
      token.token_type = :password_reset
      token.save!
      token
    end

    it "resets password with valid token" do
      new_password = "new_password123"

      puts "\nDebug Info:"
      puts "Token exists: #{VerificationToken.exists?(verification_token.id)}"
      puts "Token value: #{verification_token.token}"
      puts "Token type: #{verification_token.token_type}"
      puts "Token expired?: #{verification_token.expired?}"
      puts "Associated user ID: #{verification_token.user_id}"
      puts "User email: #{user.email}"

      post "/auth/reset_password", params: {
        token: verification_token.token,
        password: new_password,
        password_confirmation: new_password
      }

      puts "\nResponse Info:"
      puts "Status: #{response.status}"
      puts "Body: #{response.body}"

      user.reload
      puts "\nUser Info:"
      puts "User valid?: #{user.valid?}"
      puts "User errors: #{user.errors.full_messages}" if user.errors.any?

      expect(response).to have_http_status(:ok)
      expect(user.authenticate(new_password)).to be_truthy
      expect(json_response["message"]).to eq("Password has been reset successfully.")
      expect(VerificationToken.exists?(verification_token.id)).to be false
    end

    it "fails with invalid token" do
      post "/auth/reset_password", params: {
        token: "invalid_token",
        password: "new_password",
        password_confirmation: "new_password"
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("Invalid or expired token")
    end
  end

  describe "POST /auth/change_password" do
    let(:user) { create(:user, password: "old_password", password_confirmation: "old_password") }
    let(:access_token) { user.generate_access_token }

    context "with valid current password" do
      it "changes password successfully" do
        post "/auth/change_password",
          params: {
            current_password: "old_password",
            new_password: "new_password123",
            new_password_confirmation: "new_password123"
          },
          headers: { "Authorization" => "Bearer #{access_token}" }

        expect(response).to have_http_status(:ok)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq(I18n.t("auth.success.password_changed"))

        # Verify new password works
        user.reload
        expect(user.authenticate("new_password123")).to be_truthy
      end

      it "fails when new passwords don't match" do
        post "/auth/change_password",
          params: {
            current_password: "old_password",
            new_password: "new_password123",
            new_password_confirmation: "different_password"
          },
          headers: { "Authorization" => "Bearer #{access_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq(I18n.t("auth.errors.password_confirmation_mismatch"))
      end
    end

    context "with invalid current password" do
      it "returns unauthorized" do
        post "/auth/change_password",
          params: {
            current_password: "wrong_password",
            new_password: "new_password123",
            new_password_confirmation: "new_password123"
          },
          headers: { "Authorization" => "Bearer #{access_token}" }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq(I18n.t("auth.errors.invalid_current_password"))
      end
    end

    context "without authentication" do
      it "returns unauthorized" do
        post "/auth/change_password",
          params: {
            current_password: "old_password",
            new_password: "new_password123",
            new_password_confirmation: "new_password123"
          }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with temporary password" do
      let(:user_with_temp_password) { create(:user, password: "temp_password", password_confirmation: "temp_password", temporary_password: true) }
      let(:temp_access_token) { user_with_temp_password.generate_access_token }

      it "changes temporary password without requiring current password" do
        post "/auth/change_password",
          params: {
            new_password: "new_password123",
            new_password_confirmation: "new_password123"
          },
          headers: { "Authorization" => "Bearer #{temp_access_token}" }

        expect(response).to have_http_status(:ok)
        expect(json_response["success"]).to be true
        expect(json_response["message"]).to eq(I18n.t("auth.success.temporary_password_changed"))

        user_with_temp_password.reload
        expect(user_with_temp_password.authenticate("new_password123")).to be_truthy
        expect(user_with_temp_password.temporary_password).to be false
      end

      it "fails when new passwords don't match for temporary password" do
        post "/auth/change_password",
          params: {
            new_password: "new_password123",
            new_password_confirmation: "different_password"
          },
          headers: { "Authorization" => "Bearer #{temp_access_token}" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["success"]).to be false
        expect(json_response["error"]).to eq(I18n.t("auth.errors.password_confirmation_mismatch"))
      end
    end
  end
end

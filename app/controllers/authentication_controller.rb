class AuthenticationController < ApplicationController
  include JsonResponse
  skip_before_action :authenticate_request, only: [ :login, :register, :verify_email, :verify_otp, :refresh_token, :customer_register, :resend_verification_email, :forgot_password, :reset_password ]

  def customer_register
    @user = User.new(phone_number: params[:phone_number], fin: params[:fin], password: params[:password], password_confirmation: params[:password_confirmation])
    customer_role = Role.find_by(name: "customer")
    @user.roles << customer_role if customer_role

    if @user.save
      response = mock_fin_api_call(params[:fin])       # Mock FIN API call

      if response[:success]
        render json: { message: "OTP sent to your phone for verification" }, status: :ok
      else
        @user.destroy
        render json: { error: "Invalid FIN number" }, status: :unprocessable_entity
      end
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def register
    @user = User.new(user_params)

    if @user.save
      role = Role.find_by(name: params[:role] || "agent")
      @user.roles << role if role

      token = @user.verification_tokens.create(token_type: :email)
      Rails.logger.info "Verification token: #{token.token}"

      UserMailer.verification_email(@user, token).deliver_later

      render json: { message: "User created successfully. Please verify your email." }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def verify_otp
    @user = User.find_by(phone_number: params[:phone_number])
    otp = params[:otp]

    response = verify_otp_with_national_id_api(@user, otp)

    if response[:success]
      user_info = get_user_info_from_national_id_api(@user.fin)

      if user_info[:success]
        @user.update(verified: true)
        @user.create_customer_profile(user_info[:data])

        access_token = @user.generate_access_token
        refresh_token = RefreshToken.generate(@user, request)

        render json: {
          access_token: access_token,
          refresh_token: refresh_token.refresh_token,
          refresh_token_expires_at: refresh_token.expires_at,
          user: { id: @user.id, roles: @user.roles.pluck(:name) }
        }, status: :ok
      else
        render json: { error: "Failed to retrieve user info from National ID" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid OTP" }, status: :unauthorized
    end
  end

  def verify_email
    token_type = params[:token_type].present? ? VerificationToken.token_types[params[:token_type].to_sym] : VerificationToken.token_types[:email]

    token = VerificationToken.find_by(token: params[:token], token_type: token_type)

    if token && !token.expired?
      user = token.user
      user.update(verified: true)
      token.destroy

      render json: { message: "Email verified successfully" }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
    end
  end

  def login
    if params[:phone_number].present?
      # Phone login
      @user = User.find_by(phone_number: params[:phone_number])

      if @user && @user.has_role?("customer")
        if @user.authenticate(params[:password])
          if @user.verified?
            access_token = @user.generate_access_token
            refresh_token = RefreshToken.generate(@user, request)

            json_success(nil, data: {
              access_token: access_token,
              refresh_token: refresh_token.refresh_token,
              refresh_token_expires_at: refresh_token.expires_at,
              user: { id: @user.id, roles: @user.roles.pluck(:name) }
            })
          else
            json_error("auth.errors.unverified_phone")
          end
        else
          json_error("auth.errors.invalid_credentials", status: :unauthorized)
        end
      else
        json_error("auth.errors.unauthorized", status: :unauthorized)
      end
    else
      # Email login
      @user = User.find_by(email: params[:email])

      if @user && @user.authenticate(params[:password])
        if @user.verified?
          access_token = @user.generate_access_token
          refresh_token = RefreshToken.generate(@user, request)

          json_success(nil, data: {
            access_token: access_token,
            refresh_token: refresh_token.refresh_token,
            refresh_token_expires_at: refresh_token.expires_at,
            user: { id: @user.id, roles: @user.roles.pluck(:name) }
          })
        else
          json_error("auth.errors.unverified_email", status: :unauthorized)
        end
      else
        json_error("auth.errors.invalid_credentials", status: :unauthorized)
      end
    end
  end

  def refresh_token
    token_record = RefreshToken.find_by(refresh_token: params[:refresh_token])

    if token_record && !token_record.expired?
      @user = token_record.user

      access_token = @user.generate_access_token

      new_refresh_token = RefreshToken.generate(@user, request)
      token_record.old_token.destroy

      render json: {
        access_token: access_token,
        refresh_token: new_refresh_token.refresh_token,
        refresh_token_expires_at: new_refresh_token.expires_at
      }, status: :ok
    else
      render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
    end
  end

  # Logout
  def logout
    token = RefreshToken.find_by(refresh_token: params[:refresh_token])

    if token
      token.destroy
      json_success("auth.success.logged_out")
    else
      json_error("auth.errors.invalid_refresh_token")
    end
  end

  def logout_all
    current_user.refresh_tokens.destroy_all
    json_success("auth.success.logged_out_all")
  end

  def resend_verification_email
    @user = User.find_by(email: params[:email])

    if @user
      if @user.verified?
        render json: { error: "Email already verified" }, status: :unprocessable_entity
      else
        token = VerificationToken.find_by(user_id: @user.id, token_type: :email)

        if token.nil? || token.expired?
          token&.destroy
          token = @user.verification_tokens.create(token_type: :email)
        end

        UserMailer.verification_email(@user, token).deliver_later

        render json: { message: "verification email has been sent." }, status: :ok
      end
    else
      render json: { error: "User not found." }, status: :not_found
    end
  end

  def forgot_password
    @user = User.find_by(email: params[:email])

    if @user
      token = @user.verification_tokens.create(token_type: :password_reset)
      if Rails.env.test?
        UserMailer.password_reset_email(@user, token).deliver_now
      else
        UserMailer.password_reset_email(@user, token).deliver_later
      end
      render json: { message: "Password reset instructions have been sent to your email." }, status: :ok
    else
      render json: { error: "User not found." }, status: :not_found
    end
  end

  def reset_password
    token = VerificationToken.find_by(token: params[:token])
    if token && !token.expired? && token.token_type == :password_reset
      user = token.user

      if params[:password] == params[:password_confirmation]
        if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          token.destroy
          render json: { message: "Password has been reset successfully." }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: "Password confirmation doesn't match password" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Invalid or expired token" }, status: :unprocessable_entity
    end
  end

def change_password
  if current_user.authenticate(params[:current_password])
    if params[:new_password] == params[:new_password_confirmation]
      if current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
        current_user.refresh_tokens.destroy_all

          json_success("auth.success.password_changed")
      else
          json_error("auth.errors.invalid_credentials", errors: current_user.errors.full_messages)
      end
    else
      json_error("auth.errors.password_confirmation_mismatch")
    end
  else
    json_error("auth.errors.invalid_current_password", status: :unauthorized)
  end
end


  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :phone_number, :fin)
  end

  def password_params
    params.permit(:current_password, :new_password, :new_password_confirmation)
  end

  def mock_fin_api_call(fin)
    # Mock implementation
    { success: true }
  end

  def verify_otp_with_national_id_api(user, otp)
    if otp == "1234"
      { success: true }
    else
      { success: false }
    end
  end

  def get_user_info_from_national_id_api(fin)
    {
      success: true,
      data: {
        full_name: "John Doe",
        gender: "male",
        birthdate: "1990-01-01",
        phone_number: "+1234567890",
        address: "Addis Ababa, Akaki Kality, Woreda 9"
      }
    }
  end
end

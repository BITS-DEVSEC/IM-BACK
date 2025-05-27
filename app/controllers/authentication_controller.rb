class AuthenticationController < ApplicationController
  include JsonResponse
  skip_before_action :authenticate_request, only: [ :login, :register, :verify_email, :verify_otp, :refresh_token, :customer_register, :resend_verification_email, :forgot_password, :reset_password ]

  def customer_register
    @user = User.new(phone_number: params[:phone_number], fin: params[:fin], password: params[:password], password_confirmation: params[:password_confirmation])
    customer_role = Role.find_by(name: "customer")
    @user.roles << customer_role if customer_role

    if @user.save
      response = mock_fin_api_call(params[:fin])

      if response[:success]
        render_success("auth.success.otp_sent")
      else
        @user.destroy
        render_error("auth.errors.invalid_fin")
      end
    else
      render_error("errors.validation_failed", errors: @user.errors.full_messages)
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

      render_success("auth.success.user_created")
    else
      render_error("errors.validation_failed", errors: @user.errors.full_messages)
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

        render_success(nil, data: {
          access_token: access_token,
          refresh_token: refresh_token.refresh_token,
          refresh_token_expires_at: refresh_token.expires_at,
          user: @user
        })
      else
        render_error("auth.errors.invalid_fin")
      end
    else
      render_error("auth.errors.invalid_otp")
    end
  end

  def verify_email
    token = VerificationToken.find_by(token: params[:token])

    if token && !token.expired?
      user = token.user
      user.update(verified: true)
      token.destroy

      render_success("auth.success.email_verified")
    else
      render_error("auth.errors.invalid_token")
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
            set_refresh_token_cookie(refresh_token)

            render_success(nil, data: {
              access_token: access_token,
              user: @user
            })
          else
            render_error("auth.errors.unverified_phone")
          end
        else
          render_error("auth.errors.invalid_credentials", status: :unauthorized)
        end
      else
        render_error("auth.errors.unauthorized", status: :unauthorized)
      end
    else
      # Email login
      @user = User.find_by(email: params[:email])

      if @user && @user.authenticate(params[:password])
        if @user.verified?
          access_token = @user.generate_access_token
          refresh_token = RefreshToken.generate(@user, request)
          set_refresh_token_cookie(refresh_token)

          render_success(nil, data: {
            access_token: access_token,
            user: @user
          })
        else
          render_error("auth.errors.unverified_email", status: :unauthorized)
        end
      else
        render_error("auth.errors.invalid_credentials", status: :unauthorized)
      end
    end
  end

  def refresh_token
    token_value = cookies.signed[:refresh_token] || params[:refresh_token]
    token_record = RefreshToken.find_by(refresh_token: token_value)

    if token_record && !token_record.expired?
      @user = token_record.user
      access_token = @user.generate_access_token
      new_refresh_token = RefreshToken.generate(@user, request)
      token_record.destroy

      set_refresh_token_cookie(new_refresh_token)

      render_success(nil, data: {
        access_token: access_token
      })
    else
      cookies.delete(:refresh_token)
      render_error("auth.errors.invalid_refresh_token", status: :unauthorized)
    end
  end

  # Logout
  def logout
    token_value = cookies.signed[:refresh_token] || params[:refresh_token]
    token = RefreshToken.find_by(refresh_token: token_value)

    if token
      token.destroy
      cookies.delete(:refresh_token)
      render_success("auth.success.logged_out")
    else
      render_error("auth.errors.invalid_refresh_token")
    end
  end

  def logout_all
    current_user.refresh_tokens.destroy_all
    render_success("auth.success.logged_out_all")
  end

  def resend_verification_email
    @user = User.find_by(email: params[:email])

    if @user
      if @user.verified?
        render_error("auth.errors.email_already_verified")
      else
        token = VerificationToken.find_by(user_id: @user.id, token_type: :email)

        if token.nil? || token.expired?
          token&.destroy
          token = @user.verification_tokens.create(token_type: :email)
        end

        UserMailer.verification_email(@user, token).deliver_later

        render_success("auth.success.verification_email_sent")
      end
    else
      render_error("auth.errors.user_not_found", status: :not_found)
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
      render_success("auth.success.password_reset_sent")
    else
      render_error("auth.errors.user_not_found", status: :not_found)
    end
  end

  def reset_password
    token = VerificationToken.find_by(token: params[:token])
    if token && !token.expired? && token.token_type == :password_reset
      user = token.user

      if params[:password] == params[:password_confirmation]
        if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          token.destroy
          render_success("auth.success.password_reset_success")
        else
          render_error("errors.validation_failed", errors: user.errors.full_messages)
        end
      else
        render_error("auth.errors.password_confirmation_mismatch")
      end
    else
      render_error("auth.errors.invalid_token")
    end
  end

  def change_password
    if current_user.authenticate(params[:current_password])
      if params[:new_password] == params[:new_password_confirmation]
        if current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
          current_user.refresh_tokens.destroy_all
          render_success("auth.success.password_changed")
        else
          render_error("errors.validation_failed", errors: current_user.errors.full_messages)
        end
      else
        render_error("auth.errors.password_confirmation_mismatch")
      end
    else
      render_error("auth.errors.invalid_current_password", status: :unauthorized)
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
        full_name: "John Doe Smith",
        gender: "male",
        birthdate: "1990-01-01",
        phone_number: "+1234567890",
        address: "Addis Ababa, Akaki Kality, Woreda 9"
      }
    }
  end

  def set_refresh_token_cookie(refresh_token)
    cookies.signed[:refresh_token] = {
      value: refresh_token.refresh_token,
      httponly: true,
      secure: Rails.env.production?,
      expires: refresh_token.expires_at,
      same_site: :lax,
      path: "/auth/refresh"
    }
  end
end

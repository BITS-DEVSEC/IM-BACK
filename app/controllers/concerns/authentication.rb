module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header

    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded["user_id"]) if decoded
      render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Unauthorized" }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: "Unauthorized - Invalid Token" }, status: :unauthorized
    rescue JWT::ExpiredSignature => e
      render json: { error: "Unauthorized - Token Expired" }, status: :unauthorized
    rescue => e
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end

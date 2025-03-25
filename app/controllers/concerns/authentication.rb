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

    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded["user_id"]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
end

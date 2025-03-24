class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :refresh_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, -> { where("expires_at > ?", Time.current) }
  scope :for_device, ->(device) { where(device: device) }

  before_validation :set_token_and_expiry, on: :create

  def expired?
    expires_at < Time.current
  end

  def set_token_and_expiry
    self.refresh_token = SecureRandom.hex(32)
    self.expires_at = 30.days.from_now
  end

  def self.generate(user, request)
    create(
      user: user,
      device: request.params[:device_id] || "unknown",
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end
end

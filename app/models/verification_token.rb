class VerificationToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true
  validates :token_type, presence: true
  validates :expires_at, presence: true

  scope :valid, -> { where("expires_at > ?", Time.current) }

  before_validation :generate_token, on: :create

  def self.token_types
    { email: 0, phone: 1, password_reset: 2 }
  end

  def token_type=(value)
    super(self.class.token_types[value])
  end

  def token_type
    self.class.token_types.key(super())
  end

  def generate_token
    self.token = SecureRandom.hex(16)
    self.expires_at = 30.minutes.from_now
  end

  def expired?
    expires_at < Time.current
  end
end

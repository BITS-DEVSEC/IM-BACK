class User < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_one :customer, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :refresh_tokens, dependent: :destroy

  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validates :password_digest, presence: true, if: -> { email.present? }
  has_secure_password

  validates :phone_number, uniqueness: true, allow_nil: true
  validates :fin, uniqueness: true, allow_nil: true

  validate :email_or_phone_present

  has_many :verification_tokens, dependent: :destroy

  def email_or_phone_present
    if email.blank? && phone_number.blank?
      errors.add(:base, "Either email or phone number must be present")
    end
  end

  def generate_access_token
    payload = {
      user_id: id,
      roles: roles.pluck(:name),
      exp: 1.hour.from_now.to_i,
      iat: Time.now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
  end

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def create_customer_profile(user_info)
    address = user_info[:address].split(",").map(&:strip)
    region =  address[0]
    subcity = address[1]
    woreda = address[2]
    name = user_info[:full_name].split(" ").map(&:strip)
    first_name, middle_name, last_name = name
    Customer.create!(
      user: self,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      birthdate: user_info[:birthdate],
      gender: user_info[:gender],
      region: region,
      subcity: subcity,
      woreda: woreda
    )
  end
end

class Insurer < ApplicationRecord
  belongs_to :user
  has_many :insurance_products
  has_one_attached :logo

  validates :name, presence: true, uniqueness: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_phone, presence: true

  private
  def validate_logo
    return unless logo.attached?

    unless logo.content_type.in?(%w[image/jpeg image/png])
      errors.add(:logo, "must be a JPEG or PNG")
    end

    if logo.byte_size > 5.megabytes
      errors.add(:logo, "must be less than 5MB")
    end
  end
end

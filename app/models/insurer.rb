class Insurer < ApplicationRecord
  belongs_to :user
  has_many :insurance_products

  validates :name, presence: true, uniqueness: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_phone, presence: true
end

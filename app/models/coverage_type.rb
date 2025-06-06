class CoverageType < ApplicationRecord
  belongs_to :insurance_type
  has_many :policies
  has_many :liability_limits
  has_many :quotation_requests
  has_many :insurance_products

  validates :name, presence: true
  validates :description, presence: true
end

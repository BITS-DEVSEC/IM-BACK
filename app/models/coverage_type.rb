class CoverageType < ApplicationRecord
  belongs_to :insurance_type
  has_many :policies
  has_many :liability_limits
end

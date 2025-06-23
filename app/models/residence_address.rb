class ResidenceAddress < ApplicationRecord
  belongs_to :customer

  validates :region, :subcity, :woreda, :zone, presence: true
  validates :is_current, uniqueness: { scope: :customer_id }, if: :is_current?

  scope :current, -> { where(is_current: true) }
  scope :previous, -> { where(is_current: false) }
end

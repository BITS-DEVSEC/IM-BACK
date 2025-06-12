class InsuranceProduct < ApplicationRecord
  belongs_to :insurer
  belongs_to :coverage_type
  has_many :quotation_requests

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :customer_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[active inactive] }

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :for_insurer, ->(insurer) { where(insurer: insurer) }
  scope :for_coverage_type, ->(coverage_type) { where(coverage_type: coverage_type) }

  delegate :insurance_type, to: :coverage_type
end

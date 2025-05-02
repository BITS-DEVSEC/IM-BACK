class Policy < ApplicationRecord
  belongs_to :user
  belongs_to :insured_entity
  belongs_to :coverage_type
  has_many :claims

  validates :policy_number, presence: true, uniqueness: true
  validates :start_date, :end_date, :premium_amount, presence: true
  validates :premium_amount, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: [ "active", "pending", "cancelled", "expired" ] }
  validate :validate_end_date_after_start_date

  private

  def validate_end_date_after_start_date
    return if end_date.nil? || start_date.nil?
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end

class LiabilityLimit < ApplicationRecord
  belongs_to :insurance_type
  belongs_to :coverage_type

  validates :benefit_type, presence: true
  validates :min_limit, :max_limit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :validate_min_max_limits
  validates :benefit_type, uniqueness: {
    scope: [ :insurance_type_id, :coverage_type_id ],
    message: "already exists for this insurance and coverage type"
  }

  scope :for_insurance_type, ->(insurance_type) { where(insurance_type: insurance_type) }
  scope :for_coverage_type, ->(coverage_type) { where(coverage_type: coverage_type) }
  scope :for_benefit_type, ->(benefit_type) { where(benefit_type: benefit_type) }

  def display_name
    "#{benefit_type} (#{min_limit} - #{max_limit})"
  end

  private

  def validate_min_max_limits
    return if min_limit.nil? || max_limit.nil?
    if min_limit >= max_limit
      errors.add(:min_limit, "must be less than maximum limit")
    end
  end
end

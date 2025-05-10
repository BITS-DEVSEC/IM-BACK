class Claim < ApplicationRecord
  belongs_to :policy

  VALID_STATUSES = [ "pending", "approved", "rejected", "paid" ].freeze

  validates :claim_number, presence: true, uniqueness: true
  validates :description, presence: true
  validates :claimed_amount, presence: true, numericality: { greater_than: 0 }
  validates :incident_date, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }

  validate :incident_date_not_in_future
  validate :incident_date_after_policy_start
  validate :valid_status_transition, if: :status_changed?

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :paid, -> { where(status: "paid") }

  private

  def incident_date_not_in_future
    if incident_date.present? && incident_date > Date.current
      errors.add(:incident_date, "cannot be in the future")
    end
  end

  def incident_date_after_policy_start
    if incident_date.present? && policy.present? && incident_date < policy.start_date
      errors.add(:incident_date, "cannot be before policy start date")
    end
  end

  def valid_status_transition
    return unless status_was.present?

    valid_transitions = {
      "pending" => [ "approved", "rejected" ],
      "approved" => [ "paid" ],
      "rejected" => [],
      "paid" => []
    }

    unless valid_transitions[status_was].include?(status)
      errors.add(:status, "cannot transition from #{status_was} to #{status}")
    end
  end
end

class Claim < ApplicationRecord
  belongs_to :policy
  has_one :claim_driver, dependent: :destroy
  has_many :claim_timelines, dependent: :destroy
  has_many_attached :documents

  accepts_nested_attributes_for :claim_driver, allow_destroy: true

  VALID_STATUSES = [ "draft", "pending", "approved", "rejected", "paid" ].freeze
  INCIDENT_TYPES = [ "collision", "theft", "fire", "natural_disaster", "vandalism", "other" ].freeze

  validates :claim_number, presence: true, uniqueness: true
  validates :description, presence: true
  validates :claimed_amount, presence: true, numericality: { greater_than: 0 }
  validates :incident_date, presence: true
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
  validates :incident_type, inclusion: { in: INCIDENT_TYPES }, allow_blank: true
  validates :settlement_amount, numericality: { greater_than: 0 }, allow_blank: true

  validate :incident_date_not_in_future
  validate :incident_date_after_policy_start
  validate :valid_status_transition, if: :status_changed?
  validate :settlement_amount_not_greater_than_claimed, if: :settlement_amount_changed?

  after_create :create_timeline_entry_for_creation
  after_update :create_timeline_entry_for_status_change, if: :saved_change_to_status?

  scope :draft, -> { where(status: "draft") }
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :paid, -> { where(status: "paid") }
  scope :by_policy, ->(policy_id) { where(policy_id: policy_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_incident_type, ->(type) { where(incident_type: type) }
  scope :by_claim_number, ->(claim_number) { where(claim_number: claim_number) }
  scope :by_from_date, ->(from_date) { where("incident_date >= ?", from_date) }
  scope :by_to_date, ->(to_date) { where("incident_date <= ?", to_date) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date_range, ->(from_date, to_date) { where(incident_date: from_date..to_date) }

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
      "draft" => [ "pending" ],
      "pending" => [ "approved", "rejected" ],
      "approved" => [ "paid" ],
      "rejected" => [],
      "paid" => []
    }

    unless valid_transitions[status_was].include?(status)
      errors.add(:status, "cannot transition from #{status_was} to #{status}")
    end
  end

  def settlement_amount_not_greater_than_claimed
    return unless settlement_amount.present? && claimed_amount.present?

    if settlement_amount > claimed_amount
      errors.add(:settlement_amount, "cannot be greater than claimed amount")
    end
  end

  public

  def can_be_submitted?
    status == "draft"
  end

  def can_be_updated_by_user?
    status == "draft"
  end

  def requires_documents?
    [ "collision", "theft", "fire" ].include?(incident_type)
  end

  def estimated_completion_date
    case status
    when "pending"
      created_at + 15.days
    when "approved"
      updated_at + 7.days
    else
      nil
    end
  end

  def days_since_submission
    return 0 unless submitted_at
    (Date.current - submitted_at.to_date).to_i
  end

  private

  def create_timeline_entry_for_creation
    ClaimTimeline.create_event(self, "created")
  end

  def create_timeline_entry_for_status_change
    ClaimTimeline.create_event(self, "status_changed")
  end
end

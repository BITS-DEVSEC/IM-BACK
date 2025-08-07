class ClaimTimeline < ApplicationRecord
  belongs_to :claim
  belongs_to :user, optional: true

  VALID_EVENT_TYPES = [
    "created", "submitted", "under_review", "approved", "rejected",
    "paid", "document_uploaded", "document_removed", "status_changed",
    "settlement_proposed", "settlement_accepted", "settlement_rejected"
  ].freeze

  validates :event_type, presence: true, inclusion: { in: VALID_EVENT_TYPES }
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :by_event_type, ->(type) { where(event_type: type) }
  scope :status_changes, -> { where(event_type: [ "submitted", "under_review", "approved", "rejected", "paid" ]) }
  scope :document_events, -> { where(event_type: [ "document_uploaded", "document_removed" ]) }

  def self.create_event(claim, event_type, user = nil, description: nil, metadata: {})
    create!(
      claim: claim,
      user: user,
      event_type: event_type,
      description: description || default_description_for(event_type, claim),
      occurred_at: Time.current,
      metadata: metadata
    )
  end

  def self.default_description_for(event_type, claim)
    case event_type
    when "created"
      "Claim #{claim.claim_number} was created"
    when "submitted"
      "Claim #{claim.claim_number} was submitted for review"
    when "under_review"
      "Claim #{claim.claim_number} is under review"
    when "approved"
      "Claim #{claim.claim_number} was approved"
    when "rejected"
      "Claim #{claim.claim_number} was rejected"
    when "paid"
      "Claim #{claim.claim_number} was paid"
    when "document_uploaded"
      "Document uploaded for claim #{claim.claim_number}"
    when "document_removed"
      "Document removed from claim #{claim.claim_number}"
    when "status_changed"
      "Status changed for claim #{claim.claim_number}"
    else
      "Event occurred for claim #{claim.claim_number}"
    end
  end

  def formatted_occurred_at
    occurred_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def user_name
    return "System" unless user
    user.full_name.presence || user.email || "System"
  end
end

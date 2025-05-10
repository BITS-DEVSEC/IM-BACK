class InsuredEntity < ApplicationRecord
  belongs_to :user
  belongs_to :insurance_type
  belongs_to :entity_type
  belongs_to :entity, polymorphic: true
  has_many :policies, dependent: :destroy

  validates :entity_id, uniqueness: { scope: [ :entity_type_id, :user_id ] }
  validate :entity_type_matches_entity

  scope :for_user, ->(user) { where(user: user) }
  scope :for_insurance_type, ->(insurance_type) { where(insurance_type: insurance_type) }
  scope :for_entity_type, ->(entity_type) { where(entity_type: entity_type) }
  scope :with_active_policies, -> {
    joins(:policies).where(policies: { status: "active" }).distinct
  }

  def active_policy
    policies.find_by(status: "active")
  end

  def has_active_policy?
    active_policy.present?
  end

  def policy_expiry_date
    active_policy&.end_date
  end

  def days_until_expiry
    return nil unless policy_expiry_date
    (policy_expiry_date - Date.current).to_i
  end

  private

  def entity_type_matches_entity
    return unless entity.present? && entity_type.present?

    expected_type = case entity
    when Vehicle
      "Vehicle"
    when Property
      "Property"
    when Person
      "Person"
    else
      nil
    end

    if expected_type.present? && entity_type.name != expected_type
      errors.add(:entity_type, "does not match entity class")
    end
  end
end

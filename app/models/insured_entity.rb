class InsuredEntity < ApplicationRecord
  belongs_to :user, class_name: "Bscf::Core::User", foreign_key: "user_id"
  belongs_to :insurance_type
  belongs_to :entity_type
  belongs_to :entity, polymorphic: true

  validates :user, presence: true
  validates :insurance_type, presence: true
  validates :entity_type, presence: true
  validates :entity, presence: true
end

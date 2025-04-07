class Policy < ApplicationRecord
  belongs_to :user, class_name: "Bscf::Core::User", foreign_key: "user_id"
  belongs_to :insured_entity
  belongs_to :coverage_type
  has_many :claims

  validates :user, presence: true
  validates :insured_entity, presence: true
  validates :coverage_type, presence: true
end

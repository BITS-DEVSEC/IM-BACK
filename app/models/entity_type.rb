class EntityType < ApplicationRecord
  has_many :insured_entities
  has_many :entity_categories
  has_many :entity_attributes

  validates :name, presence: true
end

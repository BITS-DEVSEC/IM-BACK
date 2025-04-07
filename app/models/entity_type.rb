class EntityType < ApplicationRecord
  has_many :entity_categories
  has_many :entity_attributes
  has_many :insured_entities
end

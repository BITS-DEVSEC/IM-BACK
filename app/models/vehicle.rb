class Vehicle < ApplicationRecord
  has_many :policies
  has_many :entity_categories
  has_many :entity_attributes
  has_many :insured_entities, as: :entity
end

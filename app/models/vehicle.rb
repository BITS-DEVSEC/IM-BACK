class Vehicle < ApplicationRecord
  has_one :insured_entity, as: :entity
  has_many :entity_categories, as: :entity
  has_many :entity_attributes, as: :entity
end

class AttributeDefinition < ApplicationRecord
  belongs_to :insurance_type
  has_many :attribute_metadata
  has_many :category_attributes
  has_many :entity_attributes
end

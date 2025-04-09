class AttributeDefinition < ApplicationRecord
  belongs_to :insurance_type
  has_one :attribute_metadata, dependent: :destroy
  has_many :category_attributes
  has_many :entity_attributes
end

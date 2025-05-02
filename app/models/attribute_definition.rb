class AttributeDefinition < ApplicationRecord
  belongs_to :insurance_type
  has_one :attribute_metadata, dependent: :destroy
  has_many :category_attributes
  has_many :entity_attributes

  VALID_DATA_TYPES = %w[string integer decimal boolean date].freeze

  validates :name, presence: true,
                  uniqueness: { scope: :insurance_type_id },
                  format: { with: /\A[a-z][a-z0-9_]*\z/, message: "must start with a letter and contain only lowercase letters, numbers, and underscores" }
  validates :data_type, presence: true, inclusion: { in: VALID_DATA_TYPES }
end

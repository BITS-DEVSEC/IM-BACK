class EntityAttribute < ApplicationRecord
  belongs_to :entity_type
  belongs_to :entity, polymorphic: true
  belongs_to :attribute_definition

  validates :value, presence: true
  validates :entity_type, uniqueness: {
    scope: [ :entity_id, :attribute_definition_id ],
    message: "already has this attribute"
  }
  validate :validate_value_format

  def validate_value_format
    return if attribute_definition.nil? || value.nil?

    case attribute_definition.data_type
    when "integer"
      errors.add(:value, "must be an integer") unless value.to_s =~ /\A[+-]?\d+\z/
    when "decimal"
      errors.add(:value, "must be a decimal number") unless value.to_s =~ /\A[+-]?\d+(\.\d+)?\z/
    when "boolean"
      errors.add(:value, "must be true or false") unless [ "true", "false", "1", "0" ].include?(value.to_s.downcase)
    end
  end
end

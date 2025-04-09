class EntityAttribute < ApplicationRecord
  belongs_to :entity_type
  belongs_to :entity, polymorphic: true
  belongs_to :attribute_definition
end

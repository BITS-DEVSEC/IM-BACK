class EntityCategory < ApplicationRecord
  belongs_to :entity_type
  belongs_to :category
end

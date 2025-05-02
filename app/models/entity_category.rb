class EntityCategory < ApplicationRecord
  belongs_to :entity_type
  belongs_to :entity, polymorphic: true
  belongs_to :category
  has_one :category_group, through: :category

  validates :category_id, uniqueness: {
    scope: [ :entity_id, :entity_type_id ],
    message: "has already been taken"
  }
end

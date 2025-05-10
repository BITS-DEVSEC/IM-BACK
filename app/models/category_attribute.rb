class CategoryAttribute < ApplicationRecord
  belongs_to :category
  belongs_to :attribute_definition

  validates :is_required, inclusion: { in: [ true, false ] }
  validates :attribute_definition_id, uniqueness: {
    scope: :category_id,
    message: "already exists for this category"
  }
end

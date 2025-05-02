class Category < ApplicationRecord
  belongs_to :category_group
  has_many :category_attributes
  has_many :entity_categories

  validates :name, presence: true, uniqueness: { scope: :category_group_id }
end

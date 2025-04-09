class CategoryAttribute < ApplicationRecord
  belongs_to :category
  belongs_to :attribute_definition
end

class CategoryGroup < ApplicationRecord
  belongs_to :insurance_type
  has_many :categories
end

class CategoryGroup < ApplicationRecord
  belongs_to :insurance_type
  has_many :categories, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :insurance_type_id }

  scope :vehicle_type, -> { where(name: "Vehicle Type") }
  scope :usage_type, -> { where(name: "Usage Type") }
end

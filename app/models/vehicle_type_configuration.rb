class VehicleTypeConfiguration < ApplicationRecord
  validates :vehicle_type, :usage_type, presence: true
  validates :vehicle_type, uniqueness: { scope: :usage_type }
  validates :expected_fields, presence: true
end

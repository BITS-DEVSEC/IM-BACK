class LiabilityLimit < ApplicationRecord
  belongs_to :insurance_type
  belongs_to :coverage_type
end

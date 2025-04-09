class Policy < ApplicationRecord
  belongs_to :user
  belongs_to :insured_entity
  belongs_to :coverage_type
  has_many :claims
end

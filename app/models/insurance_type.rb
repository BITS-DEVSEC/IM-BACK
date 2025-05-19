class InsuranceType < ApplicationRecord
  has_many :coverage_types
  has_many :attribute_definitions
  has_many :liability_limits
  has_many :category_groups
  has_many :insured_entities
  has_many :quotation_requests


  validates :name, presence: true
  validates :description, presence: true
end

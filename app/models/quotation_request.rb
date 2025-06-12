class QuotationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :insurance_product, optional: true
  belongs_to :coverage_type
  belongs_to :vehicle
  accepts_nested_attributes_for :vehicle

  validates :status, presence: true
  validates :form_data, presence: true
end

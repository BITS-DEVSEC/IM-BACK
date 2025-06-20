class QuotationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :insurance_product, optional: true
  belongs_to :coverage_type
  belongs_to :insured_entity

  validates :status, presence: true
  validates :form_data, presence: true
end

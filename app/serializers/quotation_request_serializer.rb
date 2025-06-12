class QuotationRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :form_data, :created_at, :updated_at
  belongs_to :user
  belongs_to :insurance_product
  belongs_to :coverage_type
  belongs_to :vehicle
end

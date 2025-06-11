class InsuranceProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :estimated_price, :customer_rating, :status
  belongs_to :coverage_type
  belongs_to :insurer
end

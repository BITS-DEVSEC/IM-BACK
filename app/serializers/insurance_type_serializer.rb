class InsuranceTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  has_many :coverage_types
end

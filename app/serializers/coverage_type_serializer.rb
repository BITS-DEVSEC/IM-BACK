class CoverageTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
  belongs_to :insurance_type, serializer: InsuranceTypeSerializer
end

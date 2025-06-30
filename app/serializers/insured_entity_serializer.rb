class InsuredEntitySerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :insurance_type, serializer: InsuranceTypeSerializer
  belongs_to :entity, polymorphic: true
end

class ResidenceAddressSerializer < ActiveModel::Serializer
  attributes :id, :region, :subcity, :woreda, :zone, :house_number
end

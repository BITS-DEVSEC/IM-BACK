class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :middle_name, :last_name, :birthdate, :gender,
             :full_name, :age, :registration_address, :total_addresses
  has_one :current_address, serializer: ResidenceAddressSerializer

  def full_name
    "#{object.first_name} #{object.middle_name} #{object.last_name}".strip
  end

  def age
    return nil unless object.birthdate
    ((Date.current - object.birthdate) / 365.25).to_i
  end

  def registration_address
    {
      region: object.region,
      subcity: object.subcity,
      woreda: object.woreda
    }
  end

  def total_addresses
    object.residence_addresses.count
  end
end

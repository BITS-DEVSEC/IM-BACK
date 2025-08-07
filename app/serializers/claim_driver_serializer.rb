class ClaimDriverSerializer < ActiveModel::Serializer
  attributes :id, :name, :phone, :license_number, :age, :occupation,
             :address, :city, :subcity, :kebele, :house_number,
             :license_issuing_region, :license_issue_date, :license_expiry_date,
             :license_grade, :full_address, :license_valid, :created_at, :updated_at

  def full_address
    object.full_address
  end

  def license_valid
    object.license_valid?
  end
end

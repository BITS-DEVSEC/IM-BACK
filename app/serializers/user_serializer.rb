
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :verified, :phone_number, :fin, :temporary_password, :roles, :created_at, :updated_at
  has_one :customer
  has_one :insurer
end

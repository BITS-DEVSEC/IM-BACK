
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :verified, :phone_number, :fin, :created_at, :updated_at
end

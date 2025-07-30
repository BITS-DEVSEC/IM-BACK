class PolicySerializer < ActiveModel::Serializer
  attributes :id, :policy_number, :start_date, :end_date, :premium_amount, :status, :created_at, :updated_at

  belongs_to :user
  belongs_to :insured_entity
  belongs_to :coverage_type
  has_many :claims
end

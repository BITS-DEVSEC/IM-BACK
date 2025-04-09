class InsuredEntity < ApplicationRecord
  belongs_to :user
  belongs_to :insurance_type
  belongs_to :entity, polymorphic: true
  belongs_to :entity_type
  has_many :policies
end

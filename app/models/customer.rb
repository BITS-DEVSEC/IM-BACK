class Customer < ApplicationRecord
  belongs_to :user
  validates :first_name, :middle_name, :last_name, :birthdate, :gender, :region, :subcity, :woreda, presence: true
end

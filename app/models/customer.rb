class Customer < ApplicationRecord
  belongs_to :user
  has_many :residence_addresses, dependent: :destroy
  has_one :current_address, -> { where(is_current: true) },
          class_name: "ResidenceAddress"

  validates :first_name, :middle_name, :last_name, :birthdate, :gender, :region, :subcity, :woreda, presence: true

  def add_residence_address(address_params)
    transaction do
      residence_addresses.where(is_current: true).update_all(is_current: false)
      residence_addresses.create!(address_params.merge(is_current: true))
    end
  end
end

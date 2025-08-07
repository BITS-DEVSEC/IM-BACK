class ClaimDriver < ApplicationRecord
  belongs_to :claim

  validates :name, presence: true
  validates :phone, presence: true, format: { with: /\A\+?[0-9\s\-\(\)]+\z/, message: "Invalid phone format" }
  validates :age, presence: true, numericality: { greater_than: 16, less_than: 100 }
  validates :license_number, presence: true
  validates :license_issue_date, presence: true
  validates :license_expiry_date, presence: true

  validate :license_expiry_after_issue
  validate :license_not_expired
  validate :driver_age_valid_for_license

  scope :with_valid_license, -> { where("license_expiry_date > ?", Date.current) }
  scope :by_city, ->(city) { where(city: city) }

  def full_address
    [ address, kebele, subcity, city ].compact.join(", ")
  end

  def license_valid?
    license_expiry_date > Date.current
  end

  private

  def license_expiry_after_issue
    return unless license_issue_date && license_expiry_date

    if license_expiry_date <= license_issue_date
      errors.add(:license_expiry_date, "must be after issue date")
    end
  end

  def license_not_expired
    return unless license_expiry_date

    if license_expiry_date < Date.current
      errors.add(:license_expiry_date, "license is expired")
    end
  end

  def driver_age_valid_for_license
    return unless age && license_issue_date

    years_difference = Date.current.year - license_issue_date.year
    age_when_issued = age - years_difference

    if age_when_issued < 16
      errors.add(:age, "driver was too young when license was issued")
    end
  end
end

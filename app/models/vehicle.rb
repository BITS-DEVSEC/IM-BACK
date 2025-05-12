class Vehicle < ApplicationRecord
  has_one :insured_entity, as: :entity
  has_many :entity_categories, as: :entity
  has_many :entity_attributes, as: :entity

  has_one_attached :front_view_photo
  has_one_attached :back_view_photo
  has_one_attached :left_view_photo
  has_one_attached :right_view_photo
  has_one_attached :engine_photo
  has_one_attached :chassis_number_photo
  has_one_attached :libre_photo
  has_one_attached :license

  validate :validate_photo_attachments

  validates :plate_number, presence: true, uniqueness: true,
            format: { with: /\A[A-Z0-9]{3,10}\z/, message: "has invalid format" }
  validates :chassis_number, presence: true, uniqueness: true
  validates :engine_number, presence: true, uniqueness: true
  validates :year_of_manufacture, presence: true,
            numericality: { only_integer: true, greater_than: 1950, less_than_or_equal_to: -> { Date.current.year } }
  validates :make, presence: true
  validates :model, presence: true
  validates :estimated_value, presence: true, numericality: { greater_than: 0 }

  validate :year_not_in_future
  validate :year_not_too_old

  scope :by_make, ->(make) { where(make: make) }
  scope :by_model, ->(model) { where(model: model) }
  scope :by_year_range, ->(min_year, max_year) { where(year_of_manufacture: min_year..max_year) }
  scope :by_value_range, ->(min_value, max_value) { where(estimated_value: min_value..max_value) }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :most_valuable_first, -> { order(estimated_value: :desc) }

  def full_name
    "#{make} #{model} (#{year_of_manufacture})"
  end

  def age
    Date.current.year - year_of_manufacture
  end

  def new?
    age < 3
  end

  def get_attribute_value(attribute_name)
    attr_def = AttributeDefinition.find_by(name: attribute_name)
    return nil unless attr_def

    entity_attr = entity_attributes.find_by(attribute_definition: attr_def)
    entity_attr&.value
  end

  private

  def validate_photo_attachments
    photos = [
      front_view_photo,
      back_view_photo,
      left_view_photo,
      right_view_photo,
      engine_photo,
      chassis_number_photo,
      libre_photo
    ]

    photos.each do |photo|
      if photo.attached?
        unless photo.content_type.in?(%w[image/jpeg image/png])
          errors.add(photo.name, "must be a JPEG or PNG")
        end

        if photo.byte_size > 5.megabytes
          errors.add(photo.name, "must be less than 5MB")
        end
      end
    end
  end

  def year_not_in_future
    if year_of_manufacture.present? && year_of_manufacture > Date.current.year
      errors.add(:year_of_manufacture, "cannot be in the future")
    end
  end

  def year_not_too_old
    if year_of_manufacture.present? && year_of_manufacture < 1950
      errors.add(:year_of_manufacture, "is too old")
    end
  end
end

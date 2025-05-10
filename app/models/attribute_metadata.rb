class AttributeMetadata < ApplicationRecord
  belongs_to :attribute_definition

  validates :label, presence: true
  validates :is_dropdown, inclusion: { in: [ true, false ] }
  validates :dropdown_options, presence: true, if: :is_dropdown?
  validates :min_value, :max_value, numericality: true, allow_nil: true
  validate :validate_min_max_values
  validate :validate_dropdown_options_format

  private

  def validate_min_max_values
    return if min_value.nil? || max_value.nil?
    if min_value >= max_value
      errors.add(:min_value, "must be less than maximum value")
    end
  end

  def validate_dropdown_options_format
    return unless is_dropdown?
    return if dropdown_options.nil? || dropdown_options.strip.empty?

    begin
      parsed = JSON.parse(dropdown_options)
      unless parsed.is_a?(Array)
        errors.add(:dropdown_options, "must be valid JSON array")
      end
    rescue JSON::ParserError
      errors.add(:dropdown_options, "must be valid JSON array")
    end
  end
end

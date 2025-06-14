class QuotationRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :form_data, :created_at, :updated_at
  belongs_to :user
  belongs_to :insurance_product
  belongs_to :coverage_type
  belongs_to :vehicle

  def insurance_product
    object.insurance_product.as_json(include: :insurer) if object.insurance_product
  end

  def coverage_type
    object.coverage_type.as_json(include: :insurance_type) if object.coverage_type
  end
end

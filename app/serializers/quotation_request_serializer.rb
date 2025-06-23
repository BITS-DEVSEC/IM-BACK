class QuotationRequestSerializer < ActiveModel::Serializer
  attributes :id, :status, :form_data, :created_at, :updated_at, :insured_entity_data

  belongs_to :user
  belongs_to :insurance_product
  belongs_to :coverage_type
  belongs_to :insured_entity

  def insurance_product
    object.insurance_product.as_json(include: :insurer) if object.insurance_product
  end

  def coverage_type
    object.coverage_type.as_json(include: :insurance_type) if object.coverage_type
  end

  def user
    if object.user
      user_data = object.user.as_json
      user_data["customer"] = object.user.customer.as_json if object.user.customer
      user_data
    end
  end

  # This method will include the polymorphic entity's attributes
  def insured_entity_data
    entity = object.insured_entity&.entity
    return nil unless entity

    # Convention: Vehicle model maps to VehicleSerializer
    serializer_class_name = "#{entity.class.name}Serializer"

    begin
      serializer_class = serializer_class_name.constantize
      serializer_class.new(entity, scope: scope, root: false).as_json
    rescue NameError
      # Fallback if a specific serializer doesn't exist
      entity.as_json
    end
  end
end

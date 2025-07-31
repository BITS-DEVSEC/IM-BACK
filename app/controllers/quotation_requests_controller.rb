class QuotationRequestsController < ApplicationController
  include Common

  ALLOWED_ENTITY_CLASSES = [ Vehicle ].freeze

  def create
    entity_class = find_entity_class(params[:entity_type])

    service = QuotationRequestCreator.new(
      user: current_user,
      entity_class: entity_class,
      entity_params: entity_params,
      file_params: params.dig(:entity_data, :files),
      quotation_params: quotation_request_params,
      residence_address_params: residence_address_params
    )

    if (quotation_request = service.call)
      render_success(nil, data: quotation_request, status: :created)
    else
      render_error("errors.validation_failed", errors: service.errors.join(", "), status: :unprocessable_entity)
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  def convert_to_policy
    quotation_request = QuotationRequest.find(params[:id])
    policy = Policy.new(
      user_id: quotation_request.user_id,
      insured_entity_id: quotation_request.insured_entity_id,
      coverage_type_id: quotation_request.coverage_type_id,
      policy_number: "POL-#{SecureRandom.hex(8)}",
      start_date: Date.today,
      end_date: Date.today + 1.year,
      # This could be calculated
      premium_amount: quotation_request.insurance_product&.estimated_price,
      status: "pending"
    )

    if policy.save
      quotation_request.update(status: "converted")
      render_success(nil, data: policy, status: :created)
    else
      render_error("errors.validation_failed", errors: policy.errors.full_messages, status: :unprocessable_entity)
    end
  rescue StandardError => e
    render_error("errors.standard_error", error: e.message)
  end

  private

  def eager_load_associations
    [
      { user: [ :customer, :roles ] },
      { insurance_product: { coverage_type: :insurance_type } },
      { coverage_type: :insurance_type },
      { insured_entity: [ :entity, :insurance_type ] }
    ]
  end

  def serializer_includes
    {
      default: [
        :user,
        "user.customer",
        "user.customer.current_address",
        :insurance_product,
        "insurance_product.coverage_type",
        "insurance_product.coverage_type.insurance_type",
        :coverage_type,
        "coverage_type.insurance_type",
        :insured_entity,
        "insured_entity.entity",
        "insured_entity.insurance_type"
      ]
    }
  end

  def find_entity_class(type_name)
    klass = type_name.safe_constantize
    raise "Unknown entity type: #{type_name}" unless klass.in?(ALLOWED_ENTITY_CLASSES)
    klass
  end

  def entity_params
    entity_class = find_entity_class(params[:entity_type])
    params.require(:entity_data).permit(*entity_class.permitted_params)
  end

  def quotation_request_params
    params.permit(:coverage_type_id, :insurance_product_id, form_data: {})
  end

  def residence_address_params
    return nil unless params[:residence_address].present?

    params.require(:residence_address).permit(
      :region, :subcity, :woreda, :zone, :house_number
    )
  end
end

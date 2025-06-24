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

  private

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

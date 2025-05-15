class QuotationRequestsController < ApplicationController
  include Common

  def create
    begin
      raw_payload = params[:payload]
      parsed_payload = raw_payload.is_a?(String) ? JSON.parse(raw_payload) : raw_payload
      payload_params = ActionController::Parameters.new(parsed_payload).permit(
        :user_id,
        :insurance_type_id,
        :coverage_type_id,
        :status,
        form_data: {},
        vehicle_attributes: [
          :plate_number, :chassis_number, :engine_number,
          :make, :model, :year_of_manufacture, :estimated_value
        ]
      )

      quotation_request = QuotationRequest.new(payload_params.except(:vehicle_attributes))

      vehicle = Vehicle.new(payload_params[:vehicle_attributes])

      if params[:vehicle_attributes].present?
        vehicle.front_view_photo.attach(params[:vehicle_attributes]["front_view_photo"]) if params[:vehicle_attributes]["front_view_photo"].present?
        vehicle.back_view_photo.attach(params[:vehicle_attributes]["back_view_photo"]) if params[:vehicle_attributes]["back_view_photo"].present?
        vehicle.left_view_photo.attach(params[:vehicle_attributes]["left_view_photo"]) if params[:vehicle_attributes]["left_view_photo"].present?
        vehicle.right_view_photo.attach(params[:vehicle_attributes]["right_view_photo"]) if params[:vehicle_attributes]["right_view_photo"].present?
        vehicle.engine_photo.attach(params[:vehicle_attributes]["engine_photo"]) if params[:vehicle_attributes]["engine_photo"].present?
        vehicle.chassis_number_photo.attach(params[:vehicle_attributes]["chassis_number_photo"]) if params[:vehicle_attributes]["chassis_number_photo"].present?
        vehicle.libre_photo.attach(params[:vehicle_attributes]["libre_photo"]) if params[:vehicle_attributes]["libre_photo"].present?
      end

      quotation_request.vehicle = vehicle

      QuotationRequest.transaction do
        if vehicle.save && quotation_request.save
          render_success(nil, data: quotation_request, status: :created)
        else
          errors = vehicle.errors.full_messages + quotation_request.errors.full_messages
          render_error("errors.validation_failed", errors: errors, status: :unprocessable_entity)
        end
      end
    rescue JSON::ParserError => e
      render_error("errors.invalid_payload", error: "Invalid JSON payload: #{e.message}", status: :bad_request)
    rescue StandardError => e
      render_error("errors.standard_error", error: e.message, status: :internal_server_error)
    end
  end

  private

  def model_params
    raw_payload = params[:payload]
    parsed_payload = raw_payload.is_a?(String) ? JSON.parse(raw_payload) : raw_payload
    ActionController::Parameters.new(parsed_payload).permit(
      :user_id,
      :insurance_type_id,
      :coverage_type_id,
      :status,
      form_data: {},
      vehicle_attributes: [
        :plate_number, :chassis_number, :engine_number,
        :make, :model, :year_of_manufacture, :estimated_value
      ]
    )
  end
end

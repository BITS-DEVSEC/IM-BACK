class QuotationRequestsController < ApplicationController
  include Common

  private
  def model_params
    params.require(:payload).permit(
      :user_id,
      :insurance_type_id,
      :coverage_type_id,
      :status,
      form_data: {},
      vehicle_attributes: [
        :plate_number, :chassis_number, :engine_number,
        :make, :model, :engine_capacity_cc, :year_of_manufacture,
        :estimated_value,
        :front_view_photo, :back_view_photo, :left_view_photo,
        :right_view_photo, :engine_photo, :chassis_number_photo, :libre_photo
      ]

    )
  end
end

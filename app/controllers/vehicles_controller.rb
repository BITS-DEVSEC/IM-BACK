class VehiclesController < ApplicationController
  include Common
  def model_params
    params.require(:payload).permit(
      :make, :model, :year_of_manufacture, :estimated_value, :plate_number,
      :chassis_number, :engine_number, :front_view_photo, :back_view_photo,
      :left_view_photo, :right_view_photo, :engine_photo,
      :chassis_number_photo, :libre_photo
    )
  end
end

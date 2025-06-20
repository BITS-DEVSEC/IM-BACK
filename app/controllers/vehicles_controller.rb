class VehiclesController < ApplicationController
  include Common
  def model_params
    params.require(:payload).permit(*Vehicle.permitted_params, *Vehicle.file_attachments)
  end
end

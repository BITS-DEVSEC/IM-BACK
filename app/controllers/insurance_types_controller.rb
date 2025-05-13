class InsuranceTypesController < ApplicationController
  include Common

  private
  def model_params
    params.require(:payload).permit(:name, :description)
  end
end

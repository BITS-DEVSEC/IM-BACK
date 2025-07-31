class PoliciesController < ApplicationController
  include Common

  private

  def model_params
    params.require(:payload).permit(:policy_number, :start_date, :end_date, :premium_amount, :status, :user_id, :insured_entity_id, :coverage_type_id)
  end
end

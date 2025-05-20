class UsersController < ApplicationController
  include Common

  private

  def model_params
    params.require(:payload).permit(:email, :password, :password_confirmation, :phone_number, :fin)
  end
end

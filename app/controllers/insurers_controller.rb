class InsurersController < ApplicationController
  include Common

  def create
    super do
      if current_user.insurer.present?
        render_error("insurers.errors.profile_already_exists", status: :unprocessable_entity)
        return
      end

      insurer = Insurer.new(model_params.merge(user: current_user))
      if params[:payload][:logo].present?
        insurer.logo.attach(params[:payload][:logo])
      end
      [ insurer, { serializer: InsurerSerializer } ]
    end
  end

  def update
    super do
      insurer = set_object
      if params[:payload][:logo].present?
        insurer.logo.attach(params[:payload][:logo])
      end
      [ insurer, { serializer: InsurerSerializer } ]
    end
  end

  private

  def model_params
    params.require(:payload).permit(:name, :description, :contact_email, :contact_phone, :api_endpoint, :api_key, :logo)
  end
end

class InsuranceProductsController < ApplicationController
  include Common

  def create
    super do
      product = InsuranceProduct.new(model_params)
      product.insurer = current_user.insurer if current_user.insurer.present?
      [ product, { serializer: InsuranceProductSerializer } ]
    end
  end

  private

  def filter_fields
    [ :status, :coverage_type_id, :name, :insurer_id ]
  end

  def model_params
    params.require(:payload).permit(:name, :description, :estimated_price,
                                    :customer_rating, :status, :coverage_type_id)
  end
end

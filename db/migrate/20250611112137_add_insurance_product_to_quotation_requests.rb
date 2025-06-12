class AddInsuranceProductToQuotationRequests < ActiveRecord::Migration[8.0]
  def change
    add_reference :quotation_requests, :insurance_product, null: true, foreign_key: true
    remove_reference :quotation_requests, :insurance_type, foreign_key: true
  end
end

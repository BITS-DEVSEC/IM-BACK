class UpdateQuotationRequestsForInsuredEntities < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :quotation_requests, :vehicles
    remove_column :quotation_requests, :vehicle_id, :bigint

    add_reference :quotation_requests, :insured_entity, null: false, foreign_key: true
  end
end

class CreateQuotationRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :quotation_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :insurance_type, null: false, foreign_key: true
      t.references :coverage_type, null: false, foreign_key: true
      t.references :vehicle, null: false, foreign_key: true
      t.string :status, null: false, default: "draft"
      t.jsonb :form_data, null: false, default: {}

      t.timestamps
    end
  end
end

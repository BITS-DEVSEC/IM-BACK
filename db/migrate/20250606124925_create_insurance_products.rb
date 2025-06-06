class CreateInsuranceProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_products do |t|
      t.references :insurer, null: false, foreign_key: true
      t.references :coverage_type, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.decimal :estimated_price
      t.float :customer_rating
      t.string :status, null: false, default: "active"

      t.timestamps
    end
    add_index :insurance_products, :name, unique: true
    add_index :insurance_products, :status
  end
end

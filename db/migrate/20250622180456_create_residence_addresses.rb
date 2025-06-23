class CreateResidenceAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :residence_addresses do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :region, null: false
      t.string :subcity, null: false
      t.string :woreda, null: false
      t.string :zone, null: false
      t.string :house_number
      t.boolean :is_current, null: false, default: false

      t.timestamps
    end
    add_index :residence_addresses, [ :customer_id, :is_current ]
  end
end

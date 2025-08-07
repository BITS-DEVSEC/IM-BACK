class CreateClaimDrivers < ActiveRecord::Migration[8.0]
  def change
    create_table :claim_drivers do |t|
      t.references :claim, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :license_number
      t.integer :age
      t.string :occupation
      t.text :address
      t.string :city
      t.string :subcity
      t.string :kebele
      t.string :house_number
      t.string :license_issuing_region
      t.date :license_issue_date
      t.date :license_expiry_date
      t.string :license_grade

      t.timestamps
    end

    add_index :claim_drivers, :license_number
    add_index :claim_drivers, :phone
  end
end

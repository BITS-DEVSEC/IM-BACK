class CreateClaims < ActiveRecord::Migration[8.0]
  def change
    create_table :claims do |t|
      t.references :policy, null: false, foreign_key: true
      t.string :claim_number
      t.text :description
      t.decimal :claimed_amount
      t.date :incident_date
      t.string :status

      t.timestamps
    end
  end
end

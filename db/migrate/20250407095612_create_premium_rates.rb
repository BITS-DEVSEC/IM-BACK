class CreatePremiumRates < ActiveRecord::Migration[8.0]
  def change
    create_table :premium_rates do |t|
      t.references :insurance_type, null: false, foreign_key: true
      t.jsonb :criteria
      t.string :rate_type
      t.decimal :rate
      t.date :effective_date
      t.string :status

      t.timestamps
    end
  end
end

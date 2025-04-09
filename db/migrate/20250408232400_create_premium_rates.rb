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
    add_index :premium_rates, :effective_date
    add_index :premium_rates, :status
    add_index :premium_rates, :rate_type
    add_index :premium_rates, :criteria, using: 'gin'
  end
end

class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :insured_entity, null: false, foreign_key: true
      t.references :coverage_type, null: false, foreign_key: true
      t.string :policy_number
      t.date :start_date
      t.date :end_date
      t.decimal :premium_amount
      t.string :status

      t.timestamps
    end
  end
end

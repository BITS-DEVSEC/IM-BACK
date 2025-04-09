class CreateLiabilityLimits < ActiveRecord::Migration[8.0]
  def change
    create_table :liability_limits do |t|
      t.references :insurance_type, null: false, foreign_key: true
      t.references :coverage_type, null: false, foreign_key: true
      t.string :benefit_type
      t.decimal :min_limit
      t.decimal :max_limit

      t.timestamps
    end
  end
end

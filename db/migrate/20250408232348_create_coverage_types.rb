class CreateCoverageTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :coverage_types do |t|
      t.references :insurance_type, null: false, foreign_key: true
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :coverage_types, :name
  end
end

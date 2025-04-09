class CreateInsuranceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :insurance_types, :name, unique: true
  end
end

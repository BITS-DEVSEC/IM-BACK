class CreateAttributeDefinitions < ActiveRecord::Migration[8.0]
  def change
    create_table :attribute_definitions do |t|
      t.references :insurance_type, null: false, foreign_key: true
      t.string :name
      t.string :data_type

      t.timestamps
    end
    add_index :attribute_definitions, :name
  end
end

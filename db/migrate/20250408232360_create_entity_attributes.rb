class CreateEntityAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :entity_attributes do |t|
      t.references :entity_type, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: false
      t.references :attribute_definition, null: false, foreign_key: true
      t.jsonb :value

      t.timestamps
    end
  end
end

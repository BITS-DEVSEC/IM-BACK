class CreateInsuredEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :insured_entities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :insurance_type, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: false
      t.references :entity_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end

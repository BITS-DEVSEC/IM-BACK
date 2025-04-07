class CreateInsuredEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :insured_entities do |t|
      t.references :user, null: false
      t.references :insurance_type, null: false, foreign_key: true
      t.references :entity_type, null: false, foreign_key: true
      t.references :entity, polymorphic: true

      t.timestamps
    end

    add_foreign_key :insured_entities, :bscf_core_users, column: :user_id
  end
end

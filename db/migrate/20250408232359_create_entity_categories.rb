class CreateEntityCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :entity_categories do |t|
      t.references :entity_type, null: false, foreign_key: true
      t.references :entity, polymorphic: true, null: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end

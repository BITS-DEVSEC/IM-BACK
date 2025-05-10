class CreateEntityTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :entity_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :entity_types, :name, unique: true
  end
end

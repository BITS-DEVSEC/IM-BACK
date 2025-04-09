class CreateAttributeMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :attribute_metadata do |t|
      t.references :attribute_definition, null: false, foreign_key: true
      t.string :label
      t.boolean :is_dropdown
      t.jsonb :dropdown_options
      t.decimal :min_value
      t.decimal :max_value
      t.string :validation_regex
      t.text :help_text

      t.timestamps
    end
    add_index :attribute_metadata, :dropdown_options, using: 'gin'
  end
end

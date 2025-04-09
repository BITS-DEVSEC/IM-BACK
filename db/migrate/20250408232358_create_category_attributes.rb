class CreateCategoryAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :category_attributes do |t|
      t.references :category, null: false, foreign_key: true
      t.references :attribute_definition, null: false, foreign_key: true
      t.boolean :is_required

      t.timestamps
    end
  end
end

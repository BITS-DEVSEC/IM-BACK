class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.references :category_group, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
    add_index :categories, :name
  end
end

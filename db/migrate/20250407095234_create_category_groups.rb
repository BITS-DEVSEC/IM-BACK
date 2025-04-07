class CreateCategoryGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :category_groups do |t|
      t.references :insurance_type, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end

class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :name, null: false
      t.string :resource, null: false
      t.string :action, null: false

      t.timestamps
    end

    add_index :permissions, [ :name, :resource, :action ], unique: true
  end
end

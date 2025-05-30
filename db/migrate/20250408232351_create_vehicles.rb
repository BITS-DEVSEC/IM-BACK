class CreateVehicles < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicles do |t|
      t.string :plate_number
      t.string :chassis_number
      t.string :engine_number
      t.integer :year_of_manufacture
      t.string :make
      t.string :model
      t.decimal :estimated_value

      t.timestamps
    end
    add_index :vehicles, :plate_number, unique: true
    add_index :vehicles, :chassis_number, unique: true
    add_index :vehicles, :engine_number, unique: true
  end
end

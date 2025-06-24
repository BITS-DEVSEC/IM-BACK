class CreateVehicleTypeConfigurations < ActiveRecord::Migration[8.0]
  def change
    create_table :vehicle_type_configurations do |t|
      t.string :vehicle_type, null: false
      t.string :usage_type, null: false
      t.jsonb :expected_fields, null: false, default: []

      t.timestamps
    end
    add_index :vehicle_type_configurations, [ :vehicle_type, :usage_type ], unique: true
  end
end

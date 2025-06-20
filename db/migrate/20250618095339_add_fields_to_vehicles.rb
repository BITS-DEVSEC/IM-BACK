class AddFieldsToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :vehicle_type, :string, null: false
    add_column :vehicles, :usage_type, :string, null: false
    add_column :vehicles, :additional_fields, :jsonb, default: {}, null: false

    add_index :vehicles, :vehicle_type
    add_index :vehicles, :usage_type
  end
end

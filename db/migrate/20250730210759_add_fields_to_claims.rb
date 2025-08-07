class AddFieldsToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :incident_location, :string
    add_column :claims, :incident_time, :time
    add_column :claims, :incident_type, :string
    add_column :claims, :damage_description, :text
    add_column :claims, :vehicle_speed, :string
    add_column :claims, :distance_from_roadside, :string
    add_column :claims, :horn_sounded, :boolean, default: false
    add_column :claims, :inside_vehicle, :boolean, default: false
    add_column :claims, :police_notified, :boolean, default: false
    add_column :claims, :third_party_involved, :boolean, default: false
    add_column :claims, :settlement_amount, :decimal, precision: 10, scale: 2
    add_column :claims, :submitted_at, :datetime

    add_column :claims, :driver_name, :string
    add_column :claims, :driver_phone, :string
    add_column :claims, :driver_license_number, :string
    add_column :claims, :driver_age, :integer
    add_column :claims, :driver_occupation, :string
    add_column :claims, :driver_address, :text
    add_column :claims, :driver_city, :string
    add_column :claims, :driver_subcity, :string
    add_column :claims, :driver_kebele, :string
    add_column :claims, :driver_house_number, :string
    add_column :claims, :license_issuing_region, :string
    add_column :claims, :license_issue_date, :date
    add_column :claims, :license_expiry_date, :date
    add_column :claims, :license_grade, :string
    add_column :claims, :additional_details, :text

    add_index :claims, :incident_type
    add_index :claims, :submitted_at
    add_index :claims, :settlement_amount
  end
end

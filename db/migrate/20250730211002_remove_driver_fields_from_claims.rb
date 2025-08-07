class RemoveDriverFieldsFromClaims < ActiveRecord::Migration[8.0]
  def change
    remove_column :claims, :driver_name, :string
    remove_column :claims, :driver_phone, :string
    remove_column :claims, :driver_license_number, :string
    remove_column :claims, :driver_age, :integer
    remove_column :claims, :driver_occupation, :string
    remove_column :claims, :driver_address, :text
    remove_column :claims, :driver_city, :string
    remove_column :claims, :driver_subcity, :string
    remove_column :claims, :driver_kebele, :string
    remove_column :claims, :driver_house_number, :string
    remove_column :claims, :license_issuing_region, :string
    remove_column :claims, :license_issue_date, :date
    remove_column :claims, :license_expiry_date, :date
    remove_column :claims, :license_grade, :string
  end
end

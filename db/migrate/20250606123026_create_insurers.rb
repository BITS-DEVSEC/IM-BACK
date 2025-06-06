class CreateInsurers < ActiveRecord::Migration[8.0]
  def change
    create_table :insurers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :api_endpoint
      t.string :api_key
      t.string :contact_email
      t.string :contact_phone

      t.timestamps
    end
    add_index :insurers, :name, unique: true
  end
end

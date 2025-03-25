class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.date :birthdate
      t.string :gender
      t.string :region
      t.string :subcity
      t.string :woreda

      t.timestamps
    end
  end
end

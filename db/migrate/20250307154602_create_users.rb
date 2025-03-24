class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :phone_number
      t.string :fin
      t.boolean :verified, default: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :phone_number, unique: true
    add_index :users, :fin, unique: true
  end
end

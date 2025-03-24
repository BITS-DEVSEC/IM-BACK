class CreateVerificationTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :verification_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.integer :token_type, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :verification_tokens, :token, unique: true
  end
end

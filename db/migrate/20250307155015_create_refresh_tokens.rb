class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.string :device, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :refresh_tokens, :refresh_token, unique: true
  end
end

class CreateClaimTimelines < ActiveRecord::Migration[8.0]
  def change
    create_table :claim_timelines do |t|
      t.references :claim, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :event_type, null: false
      t.text :description
      t.datetime :occurred_at, null: false
      t.json :metadata

      t.timestamps
    end

    add_index :claim_timelines, :event_type
    add_index :claim_timelines, :occurred_at
    add_index :claim_timelines, [ :claim_id, :occurred_at ]
  end
end

class FixInsuredEntitiesUserForeignKey < ActiveRecord::Migration[8.0]
  def change
    # Remove the incorrect foreign key
    remove_foreign_key :insured_entities, :users

    # Ensure the correct foreign key exists
    add_foreign_key :insured_entities, :bscf_core_users, column: :user_id
  end
end

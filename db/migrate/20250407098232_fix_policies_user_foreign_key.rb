class FixPoliciesUserForeignKey < ActiveRecord::Migration[8.0]
  def change
    # Remove the incorrect foreign key
    remove_foreign_key :policies, :users

    # Add the correct foreign key
    add_foreign_key :policies, :bscf_core_users, column: :user_id
  end
end

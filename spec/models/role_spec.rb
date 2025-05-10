require 'rails_helper'

RSpec.describe Role, type: :model do
  include_examples "model_shared_spec", :role, [
    { name: [ :presence, :uniqueness ] },
    { user_roles: :have_many },
    { users: :have_many },
    { role_permissions: :have_many },
    { permissions: :have_many }
  ]
end

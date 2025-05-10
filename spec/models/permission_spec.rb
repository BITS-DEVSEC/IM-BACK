require 'rails_helper'

RSpec.describe Permission, type: :model do
  attributes = [
    { name: [ :presence, :uniqueness ] },
    { resource: [ :presence ] },
    { action: [ :presence ] },
    { role_permissions: [ :have_many ] },
    { roles: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :permission, attributes
end

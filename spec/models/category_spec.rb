require 'rails_helper'

RSpec.describe Category, type: :model do
  attributes = [
    { name: [ :presence, { uniqueness: { scope: :category_group_id } } ] },
    { category_group: [ :belong_to ] },
    { category_attributes: [ :have_many ] },
    { entity_categories: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :category, attributes
end

require 'rails_helper'

RSpec.describe EntityType, type: :model do
  attributes = [
    { name: [ :presence ] },
    { insured_entities: [ :have_many ] },
    { entity_categories: [ :have_many ] },
    { entity_attributes: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :entity_type, attributes
end

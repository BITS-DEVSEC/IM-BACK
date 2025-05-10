require 'rails_helper'

RSpec.describe EntityCategory, type: :model do
  attributes = [
    { entity: [ :belong_to ] },
    { category: [ :belong_to ] },
    { entity_type: [ :belong_to ] },
    { category_id: [
      { uniqueness: { scope: [ :entity_id, :entity_type_id ] } }
    ] }
  ]

  include_examples "model_shared_spec", :entity_category, attributes
end

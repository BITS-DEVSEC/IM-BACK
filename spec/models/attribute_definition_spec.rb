require 'rails_helper'

  RSpec.describe AttributeDefinition, type: :model do
    attributes = [
  { name: [ :presence, { uniqueness: { scope: :insurance_type_id } } ] },
      { data_type: [ :presence, { inclusion: { in: AttributeDefinition::VALID_DATA_TYPES } } ] },
      { insurance_type: [ :belong_to ] },
      { attribute_metadata: [ :have_one ] },
      { category_attributes: [ :have_many ] },
      { entity_attributes: [ :have_many ] }
    ]

    include_examples("model_shared_spec", :attribute_definition, attributes)
  end

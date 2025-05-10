require 'rails_helper'

RSpec.describe InsuranceType, type: :model do
  attributes = [
    { name: [ :presence ] },
    { description: [ :presence ] },
    { coverage_types: [ :have_many ] },
    { attribute_definitions: [ :have_many ] },
    { liability_limits: [ :have_many ] },
    { category_groups: [ :have_many ] },
    { insured_entities: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :insurance_type, attributes
end

require 'rails_helper'

RSpec.describe CoverageType, type: :model do
  attributes = [
    { name: [ :presence ] },
    { description: [ :presence ] },
    { insurance_type: [ :belong_to ] },
    { policies: [ :have_many ] },
    { liability_limits: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :coverage_type, attributes
end

require 'rails_helper'

RSpec.describe InsuranceTypesController, type: :request do
  let(:valid_attributes) { attributes_for(:insurance_type) }

  let(:invalid_attributes) { { name: nil } }

  let(:new_attributes) { { name: Faker::Company.name, description: Faker::Lorem.sentence } }

  include_examples 'request_shared_spec', 'insurance_types', 4
end

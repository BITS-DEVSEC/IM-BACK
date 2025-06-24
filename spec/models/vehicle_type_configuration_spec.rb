require 'rails_helper'

RSpec.describe VehicleTypeConfiguration, type: :model do
  attributes = [
      { vehicle_type: [ :presence, { uniqueness: { scope: :usage_type } } ] },
      { usage_type: [ :presence ] },
      { expected_fields: [ :presence ] }
  ]

  include_examples 'model_shared_spec', :vehicle_type_configuration, attributes
end

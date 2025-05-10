require 'rails_helper'

RSpec.describe Customer, type: :model do
  include_examples "model_shared_spec", :customer, [
    { first_name: :presence },
    { middle_name: :presence },
    { last_name: :presence },
    { birthdate: :presence },
    { gender: :presence },
    { region: :presence },
    { subcity: :presence },
    { woreda: :presence },
    { user: :belong_to }
  ]
end

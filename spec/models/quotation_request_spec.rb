require 'rails_helper'

RSpec.describe QuotationRequest, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { insurance_type: [ :belong_to ] },
    { coverage_type: [ :belong_to ] },
    { status: [ :presence ] },
    { form_data: [ :presence ] }
  ]

  include_examples "model_shared_spec", :quotation_request, attributes
end

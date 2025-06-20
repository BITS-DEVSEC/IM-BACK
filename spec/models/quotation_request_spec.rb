require 'rails_helper'

RSpec.describe QuotationRequest, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { insurance_product: [ { belong_to: { optional: true } } ] },
    { coverage_type: [ :belong_to ] },
    { status: [ :presence ] },
    { form_data: [ :presence ] },
    { insured_entity: [ :belong_to ] }
  ]

  include_examples "model_shared_spec", :quotation_request, attributes
end

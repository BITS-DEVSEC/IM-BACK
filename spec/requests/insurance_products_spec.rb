require 'rails_helper'

RSpec.describe InsuranceProductsController, type: :request do
  let(:coverage_type) { create(:coverage_type) }
  let(:auth_user) { create(:user) }
  let(:insurer) { create(:insurer, user: auth_user) }

  before do
    insurer
    auth_user.reload
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(auth_user)
  end
    let(:headers) do
    token = auth_user.generate_access_token
    { 'Authorization' => "Bearer #{token}" }
  end

  let(:valid_attributes) do
    {
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.paragraph,
      estimated_price: Faker::Commerce.price(range: 100..10_000.0),
      customer_rating: Faker::Number.between(from: 1, to: 5).to_f,
      status: 'active',
      coverage_type_id: coverage_type.id
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      description: nil,
      status: 'invalid_status',
      coverage_type_id: nil
    }
  end

  let(:new_attributes) do
    {
      name: "Updated Insurance Product",
      description: "Updated product description",
      estimated_price: 12_000.00
    }
  end

  include_examples 'request_shared_spec', 'insurance_products', 8
  describe 'POST /create insurer assignment' do
    it 'assigns the insurer from current_user' do
      post insurance_products_url, headers:, params: { payload: valid_attributes }, as: :json
      expect(response).to have_http_status(:created)
      expect(InsuranceProduct.last.insurer).to eq(auth_user.insurer)
    end
  end
end

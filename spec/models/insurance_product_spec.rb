require 'rails_helper'

RSpec.describe InsuranceProduct, type: :model do
  attributes = [
    { insurer: [ :belong_to ] },
    { coverage_type: [ :belong_to ] },
    { name: [ :presence ] },
    { description: [ :presence ] },
    { customer_rating: [ { numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 } } ] },
    { estimated_price: [ { numericality: { greater_than_or_equal_to: 0 } } ] },
    { status: [ :presence, { inclusion: { in: %w[active inactive] } } ] }
  ]

  include_examples "model_shared_spec", :insurance_product, attributes

  describe 'scopes' do
    let!(:active_product) { create(:insurance_product, status: 'active') }
    let!(:inactive_product) { create(:insurance_product, status: 'inactive') }
    let(:insurer) { create(:insurer) }
    let(:coverage_type) { create(:coverage_type) }
    let!(:insurer_product) { create(:insurance_product, insurer: insurer) }
    let!(:coverage_product) { create(:insurance_product, coverage_type: coverage_type) }

    it 'returns active products' do
      expect(InsuranceProduct.active).to include(active_product)
      expect(InsuranceProduct.active).not_to include(inactive_product)
    end

    it 'returns inactive products' do
      expect(InsuranceProduct.inactive).to include(inactive_product)
      expect(InsuranceProduct.inactive).not_to include(active_product)
    end

    it 'returns products for a specific insurer' do
      expect(InsuranceProduct.for_insurer(insurer)).to include(insurer_product)
    end

    it 'returns products for a specific coverage type' do
      expect(InsuranceProduct.for_coverage_type(coverage_type)).to include(coverage_product)
    end
  end

  describe 'delegations' do
    it 'delegates insurance_type to coverage_type' do
      product = build(:insurance_product)
      expect(product.coverage_type).to receive(:insurance_type)
      product.insurance_type
    end
  end
end

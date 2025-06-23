require 'rails_helper'

RSpec.describe Customer, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { residence_addresses: [ :have_many ] },
    { current_address: [ :have_one ] },
    { first_name: [ :presence ] },
    { middle_name: [ :presence ] },
    { last_name: [ :presence ] },
    { birthdate: [ :presence ] },
    { gender: [ :presence ] },
    { region: [ :presence ] },
    { subcity: [ :presence ] },
    { woreda: [ :presence ] }
  ]

  include_examples "model_shared_spec", :customer, attributes

  describe 'associations' do
    it 'destroys dependent residence_addresses when customer is destroyed' do
      customer = create(:customer, :with_multiple_addresses)
      address_ids = customer.residence_addresses.pluck(:id)

      expect { customer.destroy }.to change(ResidenceAddress, :count).by(-3)
      expect(ResidenceAddress.where(id: address_ids)).to be_empty
    end

    it 'returns the current address correctly' do
      customer = create(:customer, :with_current_address)
      current_address = customer.residence_addresses.find_by(is_current: true)

      expect(customer.current_address).to eq(current_address)
      expect(customer.current_address.is_current).to be_truthy
    end
  end

  describe '#add_residence_address' do
    let(:customer) { create(:customer, :with_current_address) }
    let(:new_address_params) do
      {
        region: 'New Region',
        subcity: 'New Subcity',
        woreda: 'New Woreda',
        zone: 'New Zone'
      }
    end

    it 'creates a new current address and marks old addresses as not current' do
      expect {
        customer.add_residence_address(new_address_params)
      }.to change(customer.residence_addresses, :count).by(1)

      customer.reload
      expect(customer.residence_addresses.where(is_current: true).count).to eq(1)
      expect(customer.current_address.region).to eq('New Region')
      expect(customer.current_address.subcity).to eq('New Subcity')
    end

    it 'ensures only one current address exists' do
      create(:residence_address, customer: customer, is_current: false)
      customer.reload

      customer.add_residence_address(new_address_params)
      customer.reload

      expect(customer.residence_addresses.where(is_current: true).count).to eq(1)
      expect(customer.residence_addresses.where(is_current: false).count).to eq(2)
    end

    it 'handles transaction rollback on failure' do
      allow(customer.residence_addresses).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

      expect {
        customer.add_residence_address(new_address_params)
      }.to raise_error(ActiveRecord::RecordInvalid)

      customer.reload
      expect(customer.residence_addresses.where(is_current: true).count).to eq(1)
    end

    it 'works when customer has no current address' do
      customer_without_current = create(:customer)

      expect {
        customer_without_current.add_residence_address(new_address_params)
      }.to change(customer_without_current.residence_addresses, :count).by(1)

      customer_without_current.reload
      expect(customer_without_current.current_address).to be_present
      expect(customer_without_current.current_address.is_current).to be_truthy
    end
  end
end

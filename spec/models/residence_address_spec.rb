require 'rails_helper'

RSpec.describe ResidenceAddress, type: :model do
  attributes = [
    { customer: [ :belong_to ] },
    { region: [ :presence ] },
    { subcity: [ :presence ] },
    { woreda: [ :presence ] },
    { zone: [ :presence ] },
    { is_current: [ { uniqueness: { scope: :customer_id } } ] }
  ]

  include_examples "model_shared_spec", :residence_address, attributes

  describe 'validations' do
    context 'is_current uniqueness' do
      let(:customer) { create(:customer) }

      it 'allows multiple addresses for same customer if only one is current' do
        create(:residence_address, customer: customer, is_current: true)
        address2 = build(:residence_address, customer: customer, is_current: false)
        address3 = build(:residence_address, customer: customer, is_current: false)

        expect(address2).to be_valid
        expect(address3).to be_valid
      end

      it 'prevents multiple current addresses for same customer' do
        create(:residence_address, customer: customer, is_current: true)
        duplicate_current = build(:residence_address, customer: customer, is_current: true)

        expect(duplicate_current).not_to be_valid
        expect(duplicate_current.errors[:is_current]).to include('has already been taken')
      end

      it 'allows current addresses for different customers' do
        customer2 = create(:customer)
        create(:residence_address, customer: customer, is_current: true)
        address_for_customer2 = build(:residence_address, customer: customer2, is_current: true)

        expect(address_for_customer2).to be_valid
      end

      it 'allows validation to pass when is_current is false' do
        create(:residence_address, customer: customer, is_current: true)
        non_current_address = build(:residence_address, customer: customer, is_current: false)

        expect(non_current_address).to be_valid
      end
    end

    context 'conditional validation' do
      it 'only validates uniqueness when is_current is true' do
        customer = create(:customer)
        create(:residence_address, customer: customer, is_current: false)
        another_non_current = build(:residence_address, customer: customer, is_current: false)

        expect(another_non_current).to be_valid
      end
    end
  end
end

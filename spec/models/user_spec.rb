require 'rails_helper'

RSpec.describe User, type: :model do
  attributes = [
    { user_roles: [ :have_many ] },
    { customer: [ :have_one ] },
    { roles: [ :have_many ] },
    { refresh_tokens: [ :have_many ] },
    { insured_entities: [ :have_many ] },
    { policies: [ :have_many ] },
    { verification_tokens: [ :have_many ] },
    { email: [ { uniqueness: { allow_nil: true } } ] },
    { phone_number: [ { uniqueness: { case_sensitive: false, allow_nil: true } } ] },
    { fin: [ { uniqueness: { allow_nil: true } } ] }
  ]

  include_examples "model_shared_spec", :user, attributes

  describe 'validations' do
    context 'email format' do
      it 'accepts valid email formats' do
        user = build(:user, email: 'test@example.com')
        expect(user).to be_valid
      end

      it 'rejects invalid email formats' do
        user = build(:user, email: 'invalid-email')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end
    end

    context 'email or phone presence' do
      it 'requires either email or phone_number to be present' do
        user = build(:user, email: nil, phone_number: nil)
        expect(user).not_to be_valid
        expect(user.errors[:base]).to include('Either email or phone number must be present')
      end

      it 'is valid with only email' do
        user = build(:user, email: 'test@example.com', phone_number: nil)
        expect(user).to be_valid
      end

      it 'is valid with only phone_number' do
        user = build(:user, email: nil, phone_number: '1234567890')
        expect(user).to be_valid
      end
    end
  end

  describe '#generate_access_token' do
    it 'generates a JWT token with correct payload' do
      user = create(:user, :with_role, role_name: 'customer')
      token = user.generate_access_token

      decoded_token = JWT.decode(
        token,
        Rails.application.credentials.secret_key_base,
        true,
        { algorithm: 'HS256' }
      ).first

      expect(decoded_token['user_id']).to eq(user.id)
      expect(decoded_token['roles']).to include('customer')
      expect(decoded_token).to have_key('exp')
      expect(decoded_token).to have_key('iat')
    end
  end

  describe '#has_role?' do
    it 'returns true when user has the specified role' do
      user = create(:user, :with_role, role_name: 'admin')
      expect(user.has_role?('admin')).to be_truthy
    end

    it 'returns false when user does not have the specified role' do
      user = create(:user, :with_role, role_name: 'customer')
      expect(user.has_role?('admin')).to be_falsey
    end
  end

  describe '#create_customer_profile' do
    let(:user) { create(:user) }
    let(:user_info) do
      {
        full_name: 'John Middle Doe',
        birthdate: '1990-01-01',
        gender: 'Male',
        address: 'Region, Subcity, Woreda'
      }
    end

    it 'creates a customer profile with the provided information' do
      expect {
        user.create_customer_profile(user_info)
      }.to change(Customer, :count).by(1)

      customer = user.customer
      expect(customer.first_name).to eq('John')
      expect(customer.middle_name).to eq('Middle')
      expect(customer.last_name).to eq('Doe')
      expect(customer.birthdate.to_s).to eq('1990-01-01')
      expect(customer.gender).to eq('Male')
      expect(customer.region).to eq('Region')
      expect(customer.subcity).to eq('Subcity')
      expect(customer.woreda).to eq('Woreda')
    end
  end
end

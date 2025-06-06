require 'rails_helper'

RSpec.describe Insurer, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { insurance_products: [ :have_many ] },
    { name: [ :presence, :uniqueness ] },
    { contact_email: [ :presence ] },
    { contact_phone: [ :presence ] }
  ]

  include_examples "model_shared_spec", :insurer, attributes

  describe 'validations' do
    it 'validates email format' do
      insurer = build(:insurer, contact_email: 'invalid-email')
      expect(insurer).not_to be_valid
      expect(insurer.errors[:contact_email]).to include('is invalid')
    end

    it 'accepts valid email format' do
      insurer = build(:insurer, contact_email: 'valid@example.com')
      expect(insurer).to be_valid
    end
  end
end

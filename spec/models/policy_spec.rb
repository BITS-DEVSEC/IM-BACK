require 'rails_helper'

RSpec.describe Policy, type: :model do
  attributes = [
    { policy_number: [ :presence, :uniqueness ] },
    { start_date: [ :presence ] },
    { end_date: [ :presence ] },
    { premium_amount: [
      :presence,
      { numericality: { greater_than: 0 } }
    ] },
    { status: [
      :presence,
      { inclusion: { in: [ 'active', 'pending', 'cancelled', 'expired' ] } }
    ] },
    { user: [ :belong_to ] },
    { insured_entity: [ :belong_to ] },
    { coverage_type: [ :belong_to ] },
    { claims: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :policy, attributes

  describe 'validations' do
    let(:policy) { build(:policy) }

    it 'ensures end_date is after start_date' do
      policy.start_date = Date.current
      policy.end_date = Date.yesterday
      expect(policy).not_to be_valid
      expect(policy.errors[:end_date]).to include('must be after start date')
    end
  end
end

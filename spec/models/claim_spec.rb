require 'rails_helper'

RSpec.describe Claim, type: :model do
  attributes = [
    { policy: [ :belong_to ] },
    { claim_number: [ :presence, :uniqueness ] },
    { description: [ :presence ] },
    { claimed_amount: [ :presence, :numericality ] },
    { incident_date: [ :presence ] },
    { status: [ :presence, { inclusion: { in: [ 'pending', 'approved', 'rejected', 'paid' ] } } ] }
  ]

  include_examples "model_shared_spec", :claim, attributes

  describe 'validations' do
    subject { build(:claim) }

    it 'validates that incident_date is not in the future' do
      subject.incident_date = Date.tomorrow
      expect(subject).not_to be_valid
      expect(subject.errors[:incident_date]).to include('cannot be in the future')
    end

    it 'validates that incident_date is not before policy start date' do
      policy = create(:policy, start_date: 1.month.ago)
      subject.policy = policy
      subject.incident_date = policy.start_date - 1.day
      expect(subject).not_to be_valid
      expect(subject.errors[:incident_date]).to include('cannot be before policy start date')
    end

    it 'validates that claimed_amount is greater than zero' do
      subject.claimed_amount = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:claimed_amount]).to include('must be greater than 0')
    end
  end

  describe 'status transitions' do
    let(:claim) { create(:claim, :pending) }

    it 'can transition from pending to approved' do
      claim.status = 'approved'
      expect(claim).to be_valid
    end

    it 'can transition from pending to rejected' do
      claim.status = 'rejected'
      expect(claim).to be_valid
    end

    it 'can transition from approved to paid' do
      claim.status = 'approved'
      claim.save!
      claim.status = 'paid'
      expect(claim).to be_valid
    end

    it 'cannot transition from rejected to paid' do
      claim.status = 'rejected'
      claim.save!
      claim.status = 'paid'
      expect(claim).not_to be_valid
      expect(claim.errors[:status]).to include('cannot transition from rejected to paid')
    end
  end

  describe 'scopes', truncation: true do
    let(:policy) { create(:policy) } # Reuse one policy

    before do
      Claim.delete_all
      EntityType.delete_all # Ensure no residual EntityType records
      create(:claim, :pending, policy: policy)
      create(:claim, :approved, policy: policy)
      create(:claim, :rejected, policy: policy)
      create(:claim, :paid, policy: policy)
    end

    it 'finds pending claims' do
      expect(Claim.pending.count).to eq(1)
      expect(Claim.pending.first.status).to eq('pending')
    end

    it 'finds approved claims' do
      expect(Claim.approved.count).to eq(1)
      expect(Claim.approved.first.status).to eq('approved')
    end

    it 'finds rejected claims' do
      expect(Claim.rejected.count).to eq(1)
      expect(Claim.rejected.first.status).to eq('rejected')
    end

    it 'finds paid claims' do
      expect(Claim.paid.count).to eq(1)
      expect(Claim.paid.first.status).to eq('paid')
    end
  end
end

require 'rails_helper'

RSpec.describe Claim, type: :model do
  attributes = [
    { policy: [ :belong_to ] },
    { claim_driver: [ :have_one ] },
    { claim_timelines: [ :have_many ] },
    { claim_number: [ :presence, :uniqueness ] },
    { description: [ :presence ] },
    { claimed_amount: [ :presence, :numericality ] },
    { incident_date: [ :presence ] },
    { status: [ :presence, { inclusion: { in: [ 'draft', 'pending', 'approved', 'rejected', 'paid' ] } } ] },
    { incident_type: [ { inclusion: { in: [ 'collision', 'theft', 'fire', 'natural_disaster', 'vandalism', 'other' ] } } ] },
    { settlement_amount: [ :numericality ] }
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

    it 'validates that settlement_amount is not greater than claimed_amount' do
      subject.claimed_amount = 10000
      subject.settlement_amount = 15000
      expect(subject).not_to be_valid
      expect(subject.errors[:settlement_amount]).to include('cannot be greater than claimed amount')
    end
  end

  describe 'status transitions' do
    let(:claim) { create(:claim, :draft) }

    it 'can transition from draft to pending' do
      claim.status = 'pending'
      expect(claim).to be_valid
    end

    it 'can transition from pending to approved' do
      claim.update!(status: 'pending')
      claim.status = 'approved'
      expect(claim).to be_valid
    end

    it 'can transition from pending to rejected' do
      claim.update!(status: 'pending')
      claim.status = 'rejected'
      expect(claim).to be_valid
    end

    it 'can transition from approved to paid' do
      claim.update!(status: 'pending')
      claim.update!(status: 'approved')
      claim.status = 'paid'
      expect(claim).to be_valid
    end

    it 'cannot transition from rejected to paid' do
      claim.update!(status: 'pending')
      claim.update!(status: 'rejected')
      claim.status = 'paid'
      expect(claim).not_to be_valid
      expect(claim.errors[:status]).to include('cannot transition from rejected to paid')
    end

    it 'cannot transition from draft to approved' do
      claim.status = 'approved'
      expect(claim).not_to be_valid
      expect(claim.errors[:status]).to include('cannot transition from draft to approved')
    end
  end

  describe 'helper methods' do
    describe '#can_be_submitted?' do
      it 'returns true for draft claims' do
        claim = build(:claim, :draft)
        expect(claim.can_be_submitted?).to be true
      end

      it 'returns false for non-draft claims' do
        claim = build(:claim, :pending)
        expect(claim.can_be_submitted?).to be false
      end
    end

    describe '#can_be_updated_by_user?' do
      it 'returns true for draft and pending claims' do
        draft_claim = build(:claim, :draft)

        expect(draft_claim.can_be_updated_by_user?).to be true
      end

      it 'returns false for approved/rejected/paid claims' do
        approved_claim = build(:claim, :approved)
        rejected_claim = build(:claim, :rejected)
        paid_claim = build(:claim, :paid)

        expect(approved_claim.can_be_updated_by_user?).to be false
        expect(rejected_claim.can_be_updated_by_user?).to be false
        expect(paid_claim.can_be_updated_by_user?).to be false
      end
    end
  end

  describe 'scopes', truncation: true do
    let(:policy) { create(:policy) } # Reuse one policy

    before do
      Claim.delete_all
      EntityType.delete_all # Ensure no residual EntityType records
      @draft_claim = create(:claim, :draft, policy: policy)
      @pending_claim = create(:claim, :pending, policy: policy)
      @approved_claim = create(:claim, :approved, policy: policy)
      @rejected_claim = create(:claim, :rejected, policy: policy)
      @paid_claim = create(:claim, :paid, policy: policy)
    end

    it 'finds draft claims' do
      expect(Claim.draft.count).to eq(1)
      expect(Claim.draft.first.status).to eq('draft')
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

    it 'filters by policy' do
      other_policy = create(:policy)
      create(:claim, policy: other_policy)

      expect(Claim.by_policy(policy.id).count).to eq(5)
      expect(Claim.by_policy(other_policy.id).count).to eq(1)
    end

    it 'filters by incident type' do
      collision_claim = create(:claim, incident_type: 'collision', policy: policy)
      theft_claim = create(:claim, incident_type: 'theft', policy: policy)

      expect(Claim.by_incident_type('collision')).to include(collision_claim)
      expect(Claim.by_incident_type('collision')).not_to include(theft_claim)
    end

    it 'orders by recent first' do
      recent_claims = Claim.recent.limit(2)
      expect(recent_claims.first.created_at).to be >= recent_claims.second.created_at
    end

    it 'filters by date range' do
      # Create a policy with start date 60 days ago to allow for incident dates
      date_policy = create(:policy, start_date: 60.days.ago, end_date: 30.days.from_now)
      recent_claim = create(:claim, incident_date: Date.current - 2.days, policy: date_policy)
      old_claim = create(:claim, incident_date: Date.current - 30.days, policy: date_policy)

      result = Claim.by_date_range(Date.current - 7.days, Date.current)
      expect(result).to include(recent_claim)
      expect(result).not_to include(old_claim)
    end
  end
end

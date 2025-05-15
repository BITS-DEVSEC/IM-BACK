require 'rails_helper'

RSpec.describe LiabilityLimit, type: :model do
  attributes = [
    { insurance_type: [ :belong_to ] },
    { coverage_type: [ :belong_to ] },
    { benefit_type: [ :presence ] },
    { max_limit: [ :presence, { numericality: { greater_than_or_equal_to: 0 } } ] },
    { min_limit: [ { numericality: { greater_than_or_equal_to: 0 } } ] }
    ]

  include_examples "model_shared_spec", :liability_limit, attributes

  describe 'validations' do
    subject { build(:liability_limit) }

    it 'validates uniqueness of benefit_type scoped to insurance_type and coverage_type' do
      existing = create(:liability_limit)
      subject.benefit_type = existing.benefit_type
      subject.insurance_type = existing.insurance_type
      subject.coverage_type = existing.coverage_type
      expect(subject).not_to be_valid
      expect(subject.errors[:benefit_type]).to include('already exists for this insurance and coverage type')
    end

    # Custom test for uniqueness validation with the specific error message
    it 'has a uniqueness validation with custom error message' do
      existing = create(:liability_limit)
      duplicate = build(:liability_limit,
                        benefit_type: existing.benefit_type,
                        insurance_type: existing.insurance_type,
                        coverage_type: existing.coverage_type)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:benefit_type]).to include('already exists for this insurance and coverage type')
    end

    it 'ensures min_limit is less than max_limit' do
      subject.min_limit = 5000
      subject.max_limit = 1000
      expect(subject).not_to be_valid
      expect(subject.errors[:min_limit]).to include('must be less than maximum limit')
    end

    it 'allows min_limit to be equal to zero' do
      subject.min_limit = 0
      subject.max_limit = 1000
      expect(subject).to be_valid
    end

    it 'allows max_limit to be equal to min_limit plus some value' do
      subject.min_limit = 1000
      subject.max_limit = 1000 + 500
      expect(subject).to be_valid
    end
  end

  describe 'scopes' do
    before do
      @insurance_type = create(:insurance_type)
      @coverage_type = create(:coverage_type, insurance_type: @insurance_type)
      @limit1 = create(:liability_limit, :bodily_injury, insurance_type: @insurance_type, coverage_type: @coverage_type)
      @limit2 = create(:liability_limit, :property_damage, insurance_type: @insurance_type, coverage_type: @coverage_type)
    end

    it 'filters by insurance type' do
      result = LiabilityLimit.for_insurance_type(@insurance_type)
      expect(result).to include(@limit1, @limit2)
    end

    it 'filters by coverage type' do
      result = LiabilityLimit.for_coverage_type(@coverage_type)
      expect(result).to include(@limit1, @limit2)
    end

    it 'filters by benefit type' do
      result = LiabilityLimit.for_benefit_type('Bodily Injury')
      expect(result).to include(@limit1)
      expect(result).not_to include(@limit2)
    end
  end

  describe 'associations' do
    it 'belongs to an insurance type' do
      liability_limit = create(:liability_limit)
      expect(liability_limit.insurance_type).to be_present
    end

    it 'belongs to a coverage type' do
      liability_limit = create(:liability_limit)
      expect(liability_limit.coverage_type).to be_present
    end
  end
end

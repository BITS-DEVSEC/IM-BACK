require 'rails_helper'

RSpec.describe InsuredEntity, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { insurance_type: [ :belong_to ] },
    { entity_type: [ :belong_to ] },
    { entity: [ :belong_to ] },
    { policies: [ :have_many ] },
    { entity_id: [ { uniqueness: { scope: [ :entity_type_id, :user_id ] } } ] }
  ]

  include_examples "model_shared_spec", :insured_entity, attributes

  describe 'validations' do
    subject { build(:insured_entity) }

    it 'validates uniqueness of entity scoped to entity_type and user' do
      existing = create(:insured_entity)
      subject.entity = existing.entity
      subject.entity_type = existing.entity_type
      subject.user = existing.user
      expect(subject).not_to be_valid
      expect(subject.errors[:entity_id]).to include('has already been taken')
    end

    it 'ensures entity type matches entity class' do
      vehicle = create(:vehicle)
      entity_type = create(:entity_type, name: 'Property')

      subject.entity = vehicle
      subject.entity_type = entity_type

      expect(subject).not_to be_valid
      expect(subject.errors[:entity_type]).to include('does not match entity class')
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:insurance_type) { create(:insurance_type, :motor) }
    let(:vehicle_type) { create(:entity_type, :vehicle) }

    before do
      @vehicle1 = create(:vehicle)
      @vehicle2 = create(:vehicle)

      @insured_entity1 = create(:insured_entity, user: user, insurance_type: insurance_type,
                               entity_type: vehicle_type, entity: @vehicle1)
      @insured_entity2 = create(:insured_entity, insurance_type: insurance_type,
                               entity_type: vehicle_type, entity: @vehicle2)
    end

    it 'finds entities by user' do
      entities = InsuredEntity.for_user(user)
      expect(entities).to include(@insured_entity1)
      expect(entities).not_to include(@insured_entity2)
    end

    it 'finds entities by insurance type' do
      entities = InsuredEntity.for_insurance_type(insurance_type)
      expect(entities).to include(@insured_entity1, @insured_entity2)
    end

    it 'finds entities by entity type' do
      entities = InsuredEntity.for_entity_type(vehicle_type)
      expect(entities).to include(@insured_entity1, @insured_entity2)
    end

    it 'finds entities with active policies' do
      create(:policy, :active, insured_entity: @insured_entity1)

      entities = InsuredEntity.with_active_policies
      expect(entities).to include(@insured_entity1)
      expect(entities).not_to include(@insured_entity2)
    end
  end

  describe 'methods' do
    let(:insured_entity) { create(:insured_entity, :with_vehicle) }

    before do
      create(:policy, :active, insured_entity: insured_entity,
             start_date: 1.month.ago, end_date: 11.months.from_now)
    end

    it 'returns active policy' do
      expect(insured_entity.active_policy).to be_present
      expect(insured_entity.active_policy.status).to eq('active')
    end

    it 'checks if entity has active policy' do
      expect(insured_entity.has_active_policy?).to be true
    end

    it 'returns policy expiry date' do
      expect(insured_entity.policy_expiry_date).to eq(insured_entity.active_policy.end_date)
    end

    it 'returns days until policy expiry' do
      days = (insured_entity.active_policy.end_date - Date.current).to_i
      expect(insured_entity.days_until_expiry).to eq(days)
    end
  end
end

require 'rails_helper'

RSpec.describe CategoryGroup, type: :model do
  attributes = [
    { name: [ :presence ] },
    { insurance_type: [ :belong_to ] },
    { categories: [ :have_many ] }
  ]

  include_examples "model_shared_spec", :category_group, attributes

  describe 'validations' do
    subject { build(:category_group) }

    it 'validates uniqueness of name scoped to insurance_type' do
      existing = create(:category_group)
      subject.name = existing.name
      subject.insurance_type = existing.insurance_type
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'can have many categories' do
      category_group = create(:category_group, :with_categories, categories_count: 3)
      expect(category_group.categories.count).to eq(3)
    end
  end

  describe 'scopes' do
    before do
      create(:category_group, name: 'Vehicle Type')
      create(:category_group, name: 'Usage Type')
      create(:category_group, name: 'Other Group')
    end

    it 'finds vehicle type groups' do
      expect(CategoryGroup.vehicle_type.first.name).to eq('Vehicle Type')
    end

    it 'finds usage type groups' do
      expect(CategoryGroup.usage_type.first.name).to eq('Usage Type')
    end
  end
end

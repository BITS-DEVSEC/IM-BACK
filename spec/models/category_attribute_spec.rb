require 'rails_helper'

RSpec.describe CategoryAttribute, type: :model do
  attributes = [
    { is_required: [ inclusion: { in: [ true, false ] } ] },
    { category: [ :belong_to ] },
    { attribute_definition: [ :belong_to ] }
  ]

  include_examples "model_shared_spec", :category_attribute, attributes

  describe 'custom error message for uniqueness' do
    let(:category) { create(:category) }
    let(:attribute_definition) { create(:attribute_definition) }

    before do
      create(:category_attribute, category: category, attribute_definition: attribute_definition)
    end

    it 'adds custom error message when duplicated' do
      duplicate = build(:category_attribute, category: category, attribute_definition: attribute_definition)
      duplicate.valid?
      expect(duplicate.errors[:attribute_definition_id]).to include("already exists for this category")
    end
  end
end

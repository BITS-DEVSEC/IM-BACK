require 'rails_helper'

RSpec.describe AttributeMetadata, type: :model do
  attributes = [
    { label: [ :presence ] },
    { is_dropdown: [ inclusion: { in: [ true, false ] } ] },
    { min_value: [ :numericality ] },
    { max_value: [ :numericality ] },
    { attribute_definition: [ :belong_to ] }
  ]

  include_examples "model_shared_spec", :attribute_metadata, attributes

  describe 'custom validations' do
    subject { build(:attribute_metadata) }

    context 'when is_dropdown is true' do
      before { subject.is_dropdown = true }

      it 'requires dropdown_options' do
        subject.dropdown_options = nil
        expect(subject).to be_invalid
        expect(subject.errors[:dropdown_options]).to include("can't be blank")
      end

      it 'validates JSON format of dropdown_options' do
        subject.dropdown_options = 'not_json'
        subject.valid?
        expect(subject.errors[:dropdown_options]).to include("must be valid JSON array")
      end

      it 'accepts valid JSON array' do
        subject.dropdown_options = '["Option 1", "Option 2"]'
        expect(subject).to be_valid
      end
    end

    context 'when is_dropdown is false' do
      it 'does not require dropdown_options' do
        subject.is_dropdown = false
        subject.dropdown_options = nil
        expect(subject).to be_valid
      end
    end

    it 'validates min_value < max_value' do
      subject.min_value = 10
      subject.max_value = 5
      subject.valid?
      expect(subject.errors[:min_value]).to include("must be less than maximum value")
    end
  end
end

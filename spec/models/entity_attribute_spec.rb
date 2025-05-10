require 'rails_helper'

RSpec.describe EntityAttribute, type: :model do
  attributes = [
    { entity_type: [ :belong_to ] },
    { entity: [ :belong_to ] },
    { attribute_definition: [ :belong_to ] },
    { value: [ :presence ] }
    # Removed uniqueness validation from shared examples to test explicitly
  ]

  include_examples "model_shared_spec", :entity_attribute, attributes

  describe "validations" do
    subject { build(:entity_attribute, :decimal) } # Use :decimal trait for consistency

    it "validates uniqueness of entity_type scoped to entity_id and attribute_definition_id with custom message" do
      entity = create(:vehicle)
      entity_type = create(:entity_type)
      attribute_definition = create(:attribute_definition, :decimal)
      create(:entity_attribute, :decimal, entity: entity, entity_type: entity_type, attribute_definition: attribute_definition)
      duplicate = build(:entity_attribute, :decimal, entity: entity, entity_type: entity_type, attribute_definition: attribute_definition)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:entity_type]).to include("already has this attribute")
    end
  end

  describe "when validating uniqueness of entity_type with scope and custom message", truncation: true do
    let(:entity) { create(:vehicle) }

    it "is invalid if another EntityAttribute with the same entity_type, entity, and attribute_definition already exists" do
      entity_type = create(:entity_type)
      attribute_definition = create(:attribute_definition, :decimal)
      create(:entity_attribute, :decimal, entity_type: entity_type, entity: entity, attribute_definition: attribute_definition)
      duplicate_entity_attribute = build(:entity_attribute, :decimal, entity_type: entity_type, entity: entity, attribute_definition: attribute_definition)
      expect(duplicate_entity_attribute).not_to be_valid
      expect(duplicate_entity_attribute.errors[:entity_type]).to include("already has this attribute")
    end

    it "is valid when entity_type, entity, and attribute_definition are unique" do
      entity_type_2 = create(:entity_type)  # Only need the second one for this test
      attribute_definition_2 = create(:attribute_definition, :decimal)  # Same for attribute_definition_2
      valid_entity_attribute = build(:entity_attribute, :decimal, entity_type: entity_type_2, entity: entity, attribute_definition: attribute_definition_2)
      expect(valid_entity_attribute).to be_valid
    end
  end
end

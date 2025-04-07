require 'bscf/core'

puts "Clearing existing data..."

LiabilityLimit.destroy_all
PremiumRate.destroy_all
Policy.destroy_all
CategoryAttribute.destroy_all
AttributeMetadatum.destroy_all
AttributeDefinition.destroy_all
EntityCategory.destroy_all
Category.destroy_all
CategoryGroup.destroy_all
InsuredEntity.destroy_all
Vehicle.destroy_all
CoverageType.destroy_all
EntityType.destroy_all
InsuranceType.destroy_all

Bscf::Core::UserProfile.destroy_all
Bscf::Core::VirtualAccount.destroy_all
Bscf::Core::UserRole.destroy_all
Bscf::Core::Business.destroy_all
Bscf::Core::User.destroy_all
Bscf::Core::Address.destroy_all

puts "Seeding core user..."
user = Bscf::Core::User.create!(
  first_name: "John",
  middle_name: "Doe",
  last_name: "Smith",
  email: "john.doe@example.com",
  phone_number: "+251911234567",
  password: "password123",
  password_confirmation: "password123"
)

puts "Creating core user profile..."
address = Bscf::Core::Address.create!(
  city: "Addis Ababa",
  sub_city: "Bole",
  woreda: "03"
)

Bscf::Core::UserProfile.create!(
  user: user,
  date_of_birth: Date.new(1990, 1, 1),
  nationality: "Ethiopian",
  occupation: "Professional",
  source_of_funds: "Employment",
  kyc_status: 0,
  gender: 0,
  address: address
)

puts "Seeding insurance types..."
motor_insurance = InsuranceType.create!(
  name: "Motor",
  description: "Motor vehicle insurance"
)

health_insurance = InsuranceType.create!(
  name: "Health",
  description: "Health insurance for individuals"
)

puts "Seeding coverage types..."
motor_third_party = CoverageType.create!(
  insurance_type: motor_insurance,
  name: "Third Party",
  description: "Covers third-party risks for motor vehicles"
)

puts "Seeding entity types..."
vehicle_entity_type = EntityType.create!(
  name: "Vehicle"
)

puts "Creating sample vehicle..."
vehicle = Vehicle.create!(
  plate_number: "A12345",
  chassis_number: "CHASSIS123456",
  engine_number: "ENGINE123456",
  year_of_manufacture: 2020,
  make: "Toyota",
  model: "Corolla",
  estimated_value: 1500000.00
)

puts "Creating insured entity..."
insured_entity = InsuredEntity.create!(
  user: user,
  insurance_type: motor_insurance,
  entity_type: vehicle_entity_type,
  entity: vehicle
)

puts "Creating policy..."
policy = Policy.create!(
  user: user,
  insured_entity: insured_entity,
  coverage_type: motor_third_party
)

puts "Seeding category groups..."
vehicle_type_group = CategoryGroup.create!(
  insurance_type: motor_insurance,
  name: "Vehicle Type"
)

usage_type_group = CategoryGroup.create!(
  insurance_type: motor_insurance,
  name: "Usage Type"
)

puts "Seeding categories..."
private_vehicle = Category.create!(
  category_group: vehicle_type_group,
  name: "Private Vehicle"
)

minibus = Category.create!(
  category_group: vehicle_type_group,
  name: "Minibus"
)

bus = Category.create!(
  category_group: vehicle_type_group,
  name: "Bus"
)

truck = Category.create!(
  category_group: vehicle_type_group,
  name: "Truck"
)

private_own_use = Category.create!(
  category_group: usage_type_group,
  name: "Private Own Use"
)

private_business_use = Category.create!(
  category_group: usage_type_group,
  name: "Private Business Use"
)

public_service = Category.create!(
  category_group: usage_type_group,
  name: "Public Service"
)

commercial_use = Category.create!(
  category_group: usage_type_group,
  name: "Commercial Use"
)

puts "Seeding attribute definitions..."
engine_capacity = AttributeDefinition.create!(
  insurance_type: motor_insurance,
  name: "engine_capacity",
  data_type: "integer"
)

passenger_capacity = AttributeDefinition.create!(
  insurance_type: motor_insurance,
  name: "passenger_capacity",
  data_type: "integer"
)

load_capacity = AttributeDefinition.create!(
  insurance_type: motor_insurance,
  name: "load_capacity",
  data_type: "decimal"
)

puts "Seeding attribute metadata..."
AttributeMetadatum.create!(
  attribute_definition: engine_capacity,
  label: "Engine Capacity (CC)",
  is_dropdown: false,
  min_value: 0,
  max_value: 5000,
  help_text: "Vehicle engine capacity in cubic centimeters"
)

AttributeMetadatum.create!(
  attribute_definition: passenger_capacity,
  label: "Passenger Capacity",
  is_dropdown: false,
  min_value: 1,
  max_value: 100,
  help_text: "Maximum number of passengers"
)

AttributeMetadatum.create!(
  attribute_definition: load_capacity,
  label: "Load Capacity (Quintals)",
  is_dropdown: false,
  min_value: 0,
  max_value: 1000,
  help_text: "Maximum load capacity in quintals"
)

puts "Seeding category attributes..."
CategoryAttribute.create!(
  category: private_vehicle,
  attribute_definition: engine_capacity,
  is_required: true
)

CategoryAttribute.create!(
  category: minibus,
  attribute_definition: passenger_capacity,
  is_required: true
)

CategoryAttribute.create!(
  category: bus,
  attribute_definition: passenger_capacity,
  is_required: true
)

CategoryAttribute.create!(
  category: truck,
  attribute_definition: load_capacity,
  is_required: true
)

puts "Seeding premium rates..."
PremiumRate.create!(
  insurance_type: motor_insurance,
  criteria: {
    categories: {
      "Vehicle Type" => "Private Vehicle",
      "Usage Type" => "Private Own Use"
    },
    attributes: {
      "engine_capacity" => { "min" => 0, "max" => 1600 }
    }
  },
  rate_type: "Fixed",
  rate: 2641,
  effective_date: Date.current,
  status: "Active"
)

puts "Seeding liability limits..."
LiabilityLimit.create!(
  insurance_type: motor_insurance,
  coverage_type: motor_third_party,
  benefit_type: "Bodily Injury",
  max_limit: 250000
)

LiabilityLimit.create!(
  insurance_type: motor_insurance,
  coverage_type: motor_third_party,
  benefit_type: "Death",
  min_limit: 30000,
  max_limit: 250000
)

LiabilityLimit.create!(
  insurance_type: motor_insurance,
  coverage_type: motor_third_party,
  benefit_type: "Property Damage",
  max_limit: 200000
)

LiabilityLimit.create!(
  insurance_type: motor_insurance,
  coverage_type: motor_third_party,
  benefit_type: "Emergency Medical Treatment",
  max_limit: 15000
)

puts "Seeding complete!"

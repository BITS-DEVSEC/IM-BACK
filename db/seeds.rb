# Clear existing data to start fresh
puts "Cleaning up existing data..."
RolePermission.destroy_all
Permission.destroy_all
Role.destroy_all
User.destroy_all

puts "Creating roles..."
roles = [
  { name: 'admin' },
  { name: 'agent' },
  { name: 'customer' },
  { name: 'manager' }
]

roles.each do |role|
  Role.find_or_create_by!(name: role[:name])
end

puts "Creating permissions..."
permissions = [
  { name: 'read_policies', resource: 'insurance_policies', action: 'read' },
  { name: 'create_policies', resource: 'insurance_policies', action: 'create' },
  { name: 'update_policies', resource: 'insurance_policies', action: 'update' },
  { name: 'delete_policies', resource: 'insurance_policies', action: 'delete' }
]

permissions.each do |permission|
  Permission.find_or_create_by!(permission)
end

puts "Creating user management permissions..."
user_permissions = [
  { name: 'read_users', resource: 'users', action: 'read' },
  { name: 'create_users', resource: 'users', action: 'create' },
  { name: 'update_users', resource: 'users', action: 'update' },
  { name: 'delete_users', resource: 'users', action: 'delete' },
  { name: 'manage_users', resource: 'users', action: 'manage' }
]

user_permissions.each do |permission|
  Permission.find_or_create_by!(permission)
end

puts "Assigning permissions to roles..."
# Get role references
admin_role = Role.find_by!(name: 'admin')
agent_role = Role.find_by!(name: 'agent')
customer_role = Role.find_by!(name: 'customer')
manager_role = Role.find_by!(name: 'manager')

# Admin has all permissions
Permission.all.find_each do |permission|
  RolePermission.find_or_create_by!(role: admin_role, permission: permission)
end

# Agents can read and create policies
Permission.where(name: [ 'read_policies', 'create_policies' ]).find_each do |permission|
  RolePermission.find_or_create_by!(role: agent_role, permission: permission)
end

# Customers can only read policies
Permission.where(name: 'read_policies').find_each do |permission|
  RolePermission.find_or_create_by!(role: customer_role, permission: permission)
end

# Managers can read, create and update policies
Permission.where(name: [ 'read_policies', 'create_policies', 'update_policies' ]).find_each do |permission|
  RolePermission.find_or_create_by!(role: manager_role, permission: permission)
end

# Admin gets all user permissions
Permission.where(resource: 'users').find_each do |permission|
  RolePermission.find_or_create_by!(role: admin_role, permission: permission)
end

# Managers can read and update users
Permission.where(resource: 'users', action: [ 'read', 'update' ]).find_each do |permission|
  RolePermission.find_or_create_by!(role: manager_role, permission: permission)
end

puts "Creating default users..."
# Create default users
default_users = [
  { email: 'admin@example.com', role: admin_role },
  { email: 'manager@example.com', role: manager_role },
  { email: 'agent@example.com', role: agent_role },
  { email: 'customer@example.com', role: customer_role }
]

default_users.each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.verified = true
  end

  # Safely assign role
  unless user.roles.include?(user_data[:role])
    user.roles = [ user_data[:role] ]
    user.save!
  end
end

puts "\nSeeding insurance data..."

LiabilityLimit.destroy_all
PremiumRate.destroy_all
Policy.destroy_all
CategoryAttribute.destroy_all
AttributeMetadata.destroy_all
AttributeDefinition.destroy_all
EntityCategory.destroy_all
Category.destroy_all
CategoryGroup.destroy_all
InsuredEntity.destroy_all
Vehicle.destroy_all
CoverageType.destroy_all
EntityType.destroy_all
InsuranceType.destroy_all

user = User.find_by!(email: 'customer@example.com')

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
  coverage_type: motor_third_party,
  policy_number: "POL-#{Time.current.to_i}",
  start_date: Date.current,
  end_date: Date.current + 1.year,
  premium_amount: 2641.00,
  status: "Active"
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
AttributeMetadata.create!(
  attribute_definition: engine_capacity,
  label: "Engine Capacity (CC)",
  is_dropdown: false,
  min_value: 0,
  max_value: 5000,
  help_text: "Vehicle engine capacity in cubic centimeters"
)

AttributeMetadata.create!(
  attribute_definition: passenger_capacity,
  label: "Passenger Capacity",
  is_dropdown: false,
  min_value: 1,
  max_value: 100,
  help_text: "Maximum number of passengers"
)

AttributeMetadata.create!(
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

puts "Insurance data seeding complete!"

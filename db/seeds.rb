puts "Cleaning up existing data..."
RolePermission.destroy_all
Permission.destroy_all
Role.destroy_all
User.destroy_all

LiabilityLimit.destroy_all
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

# Roles
puts "Creating roles..."
roles = %w[admin agent customer manager insurer]
roles.each { |name| Role.find_or_create_by!(name:) }

# Permissions
puts "Creating permissions..."
permissions = [
  { name: 'read_policies', resource: 'insurance_policies', action: 'read' },
  { name: 'create_policies', resource: 'insurance_policies', action: 'create' },
  { name: 'update_policies', resource: 'insurance_policies', action: 'update' },
  { name: 'delete_policies', resource: 'insurance_policies', action: 'delete' },
  { name: 'read_users', resource: 'users', action: 'read' },
  { name: 'create_users', resource: 'users', action: 'create' },
  { name: 'update_users', resource: 'users', action: 'update' },
  { name: 'delete_users', resource: 'users', action: 'delete' },
  { name: 'manage_users', resource: 'users', action: 'manage' },
  # Claims permissions
  { name: 'read_claims', resource: 'claims', action: 'read' },
  { name: 'create_claims', resource: 'claims', action: 'create' },
  { name: 'update_claims', resource: 'claims', action: 'update' },
  { name: 'delete_claims', resource: 'claims', action: 'delete' },
  { name: 'process_claims', resource: 'claims', action: 'process' }
]

insurer_permissions = [
  { name: 'manage_products', resource: 'insurance_products', action: 'manage' },
  { name: 'view_customers', resource: 'customers', action: 'read' },
  { name: 'view_policies', resource: 'policies', action: 'read' },
  { name: 'view_claims', resource: 'claims', action: 'read' },
  { name: 'process_claims', resource: 'claims', action: 'process' },
  { name: 'update_claim_status', resource: 'claims', action: 'update_status' }
]

permissions.each { |perm| Permission.find_or_create_by!(perm) }
insurer_permissions.each { |perm| Permission.find_or_create_by!(perm) }

# Role Permissions
puts "Assigning permissions to roles..."
admin = Role.find_by!(name: 'admin')
agent = Role.find_by!(name: 'agent')
customer = Role.find_by!(name: 'customer')
manager = Role.find_by!(name: 'manager')
insurer = Role.find_by!(name: 'insurer')

Permission.all.find_each { |p| RolePermission.find_or_create_by!(role: admin, permission: p) }

Permission.where(name: %w[read_policies create_policies]).each do |p|
  RolePermission.find_or_create_by!(role: agent, permission: p)
end

# Customer permissions - can read policies and manage their own claims
RolePermission.find_or_create_by!(role: customer, permission: Permission.find_by!(name: 'read_policies'))
Permission.where(name: %w[read_claims create_claims update_claims]).each do |p|
  RolePermission.find_or_create_by!(role: customer, permission: p)
end

Permission.where(name: %w[read_policies create_policies update_policies]).each do |p|
  RolePermission.find_or_create_by!(role: manager, permission: p)
end

Permission.where(resource: 'users', action: %w[read update]).each do |p|
  RolePermission.find_or_create_by!(role: manager, permission: p)
end

# Manager can also view and process claims
Permission.where(name: %w[read_claims process_claims]).each do |p|
  RolePermission.find_or_create_by!(role: manager, permission: p)
end

insurer_permissions.each do |perm_attrs|
  permission = Permission.find_by!(name: perm_attrs[:name])
  RolePermission.find_or_create_by!(role: insurer, permission: permission)
end
# Users
puts "Creating default users..."
[
  { email: 'admin@example.com', role: admin },
  { email: 'manager@example.com', role: manager },
  { email: 'agent@example.com', role: agent },
  { email: 'customer@example.com', role: customer },
  { email: 'insurer@example.com', role: insurer }
].each do |data|
  user = User.find_or_create_by!(email: data[:email]) do |u|
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.verified = true
  end
  user.roles = [ data[:role] ]
  user.save!
end

# Insurance Types
puts "Seeding insurance types..."
insurance_types = {
  'Motor' => 'Motor vehicle insurance',
  'Home' => 'Home and property insurance',
  'Life' => 'Life insurance for individuals'
}

insurance_type_records = {}
insurance_types.each do |name, desc|
  insurance_type_records[name] = InsuranceType.find_or_create_by!(name:) { |it| it.description = desc }
end

# Coverage Types
puts "Seeding coverage types..."
coverage_data = {
  'Motor' => [
    { name: 'Third Party', description: 'Covers third-party risks for motor vehicles' },
    { name: 'Own Damage', description: 'Covers damage to the insured vehicle' },
    { name: 'Comprehensive', description: 'Covers all risks for motor vehicles' }
  ],
  'Home' => [
    { name: 'Fire Damage', description: 'Covers damages caused by fire' },
    { name: 'Theft', description: 'Covers theft and burglary losses' }
  ],
  'Life' => [
    { name: 'Term Plan', description: 'Coverage for a fixed term' },
    { name: 'Whole Life', description: 'Lifelong protection' }
  ]
}

coverage_data.each do |ins_type_name, coverages|
  ins_type = insurance_type_records[ins_type_name]
  coverages.each do |ct|
    CoverageType.find_or_create_by!(insurance_type: ins_type, name: ct[:name]) do |c|
      c.description = ct[:description]
    end
  end
end

# Entity Types and Vehicles
puts "Seeding entity types and vehicles..."
vehicle_entity_type = EntityType.find_or_create_by!(name: 'Vehicle')

vehicle = Vehicle.find_or_create_by!(plate_number: 'A12345') do |v|
  v.chassis_number = 'CHASSIS123456'
  v.engine_number = 'ENGINE123456'
  v.year_of_manufacture = 2020
  v.make = 'Toyota'
  v.model = 'Corolla'
  v.estimated_value = 1_500_000.00
  v.vehicle_type = 'Private Vehicle'
  v.usage_type = 'Private Own Use'
  v.additional_fields = {}
end

customer_user = User.find_by!(email: 'customer@example.com')

insured_entity = InsuredEntity.create!(
  user: customer_user,
  insurance_type: insurance_type_records['Motor'],
  entity_type: vehicle_entity_type,
  entity: vehicle
)

# Policy
puts "Creating a sample policy..."
third_party = CoverageType.find_by!(name: 'Third Party', insurance_type: insurance_type_records['Motor'])

policy = Policy.create!(
  user: customer_user,
  insured_entity: insured_entity,
  coverage_type: third_party,
  policy_number: "POL-#{Time.current.to_i}",
  start_date: Date.current - 6.months,
  end_date: Date.current + 6.months,
  premium_amount: 2641.00,
  status: 'active'
)

# Sample Claims
puts "Creating sample claims..."

# Claim 1: Recent collision (approved)
claim1 = Claim.create!(
  policy: policy,
  claim_number: "CL-2024-0042",
  description: "Minor collision with another vehicle at an intersection. Front bumper damaged.",
  claimed_amount: 15000.0,
  settlement_amount: nil,
  incident_date: Date.current - 30.days,
  incident_time: '14:30',
  incident_location: "Bole Road, Addis Ababa",
  incident_type: "collision",
  damage_description: "Minor collision with another vehicle at an intersection. Front bumper damaged.",
  vehicle_speed: "40 km/h",
  distance_from_roadside: "2 meters",
  horn_sounded: false,
  inside_vehicle: false,
  police_notified: false,
  third_party_involved: false,
  status: "approved",
  submitted_at: Date.current - 25.days,
  additional_details: "Intersection collision with minor damage"
)

# Create driver info for claim 1
ClaimDriver.create!(
  claim: claim1,
  name: "Samuel Asmare Zerif",
  phone: "0916350638",
  license_number: "DL123456789",
  age: 32,
  city: "Addis Ababa",
  subcity: "Kirkos",
  kebele: "12",
  house_number: "1234",
  license_grade: "Grade 3",
  license_issuing_region: "Addis Ababa",
  license_issue_date: Date.current - 5.years,
  license_expiry_date: Date.current + 3.years,
  occupation: "Software Engineer"
)

# Create timeline entries for claim 1
ClaimTimeline.create!(
  claim: claim1,
  event_type: "created",
  user: customer_user,
  occurred_at: Date.current - 30.days,
  description: "Claim created"
)

ClaimTimeline.create!(
  claim: claim1,
  event_type: "submitted",
  user: customer_user,
  occurred_at: Date.current - 25.days,
  description: "Claim submitted for review"
)

ClaimTimeline.create!(
  claim: claim1,
  event_type: "status_changed",
  user: User.find_by!(email: 'admin@example.com'),
  occurred_at: Date.current - 20.days,
  description: "Status changed to approved"
)

# Claim 2: Completed claim
claim2 = Claim.create!(
  policy: policy,
  claim_number: "CL-2024-0028",
  description: "Toyota Corolla - Bumper Repair. Vehicle damage from parking lot incident.",
  claimed_amount: 12500.0,
  settlement_amount: 12500.0,
  incident_date: Date.current - 90.days,
  incident_time: '09:15',
  incident_location: "Shopping mall parking lot",
  incident_type: "collision",
  damage_description: "Rear bumper damage from backing into a pole",
  vehicle_speed: "5 km/h",
  police_notified: false,
  third_party_involved: false,
  status: "paid",
  submitted_at: Date.current - 85.days,
  additional_details: "Parking lot surveillance footage available"
)

# Create driver info for claim 2
ClaimDriver.create!(
  claim: claim2,
  name: "Samuel Asmare Zerif",
  phone: "0916350638",
  license_number: "DL123456789",
  age: 32,
  city: "Addis Ababa",
  subcity: "Kirkos",
  kebele: "12",
  house_number: "1234",
  license_grade: "Grade 3",
  license_issuing_region: "Addis Ababa",
  license_issue_date: Date.current - 5.years,
  license_expiry_date: Date.current + 3.years,
  occupation: "Software Engineer"
)

# Create timeline entries for claim 2
ClaimTimeline.create!(
  claim: claim2,
  event_type: "created",
  user: customer_user,
  occurred_at: Date.current - 90.days,
  description: "Claim created"
)

ClaimTimeline.create!(
  claim: claim2,
  event_type: "submitted",
  user: customer_user,
  occurred_at: Date.current - 85.days,
  description: "Claim submitted for review"
)

ClaimTimeline.create!(
  claim: claim2,
  event_type: "status_changed",
  user: User.find_by!(email: 'admin@example.com'),
  occurred_at: Date.current - 80.days,
  description: "Status changed to approved"
)

ClaimTimeline.create!(
  claim: claim2,
  event_type: "status_changed",
  user: User.find_by!(email: 'admin@example.com'),
  occurred_at: Date.current - 75.days,
  description: "Status changed to paid",
  metadata: { settlement_amount: 12500.0 }
)

# Claim 3: Draft claim
claim3 = Claim.create!(
  policy: policy,
  claim_number: "CL-2024-0055",
  description: "Draft claim for windshield replacement",
  claimed_amount: 3500.0,
  incident_date: Date.current - 5.days,
  incident_type: "other",
  damage_description: "Windshield cracked due to debris from construction site",
  status: "draft",
  additional_details: "Windshield replacement needed"
)

# Create driver info for claim 3
ClaimDriver.create!(
  claim: claim3,
  name: "Samuel Asmare Zerif",
  phone: "0916350638",
  license_number: "DL123456789",
  age: 32,
  city: "Addis Ababa",
  subcity: "Kirkos",
  kebele: "12",
  house_number: "1234",
  license_grade: "Grade 3",
  license_issuing_region: "Addis Ababa",
  license_issue_date: Date.current - 5.years,
  license_expiry_date: Date.current + 3.years,
  occupation: "Software Engineer"
)

# Create timeline entry for claim 3
ClaimTimeline.create!(
  claim: claim3,
  event_type: "created",
  user: customer_user,
  occurred_at: Date.current - 5.days,
  description: "Draft claim created"
)

puts "Sample claims created successfully!"

# Category Groups and Categories
puts "Seeding category groups and categories..."
vehicle_type_group = CategoryGroup.create!(insurance_type: insurance_type_records['Motor'], name: 'Vehicle Type')
usage_type_group = CategoryGroup.create!(insurance_type: insurance_type_records['Motor'], name: 'Usage Type')

categories = {
  vehicle_type_group => %w[Private\ Vehicle Minibus Bus Truck],
  usage_type_group => [ 'Private Own Use', 'Private Business Use', 'Public Service', 'Commercial Use' ]
}

categories.each do |group, names|
  names.each { |name| Category.find_or_create_by!(category_group: group, name:) }
end

# Attribute Definitions
puts "Seeding attribute definitions and metadata..."
definitions = {
  'engine_capacity' => { type: 'integer', label: 'Engine Capacity (CC)', min: 0, max: 5000, help: 'Vehicle engine capacity in cubic centimeters' },
  'passenger_capacity' => { type: 'integer', label: 'Passenger Capacity', min: 1, max: 100, help: 'Max passengers' },
  'load_capacity' => { type: 'decimal', label: 'Load Capacity (Quintals)', min: 0, max: 1000, help: 'Max load in quintals' }
}

definitions.each do |name, defn|
  attr_def = AttributeDefinition.create!(
    insurance_type: insurance_type_records['Motor'],
    name: name,
    data_type: defn[:type]
  )

  AttributeMetadata.create!(
    attribute_definition: attr_def,
    label: defn[:label],
    is_dropdown: false,
    min_value: defn[:min],
    max_value: defn[:max],
    help_text: defn[:help]
  )
end

# Category Attributes
puts "Linking category attributes..."
CategoryAttribute.create!(
  category: Category.find_by!(name: 'Private Vehicle'),
  attribute_definition: AttributeDefinition.find_by!(name: 'engine_capacity'),
  is_required: true
)

CategoryAttribute.create!(
  category: Category.find_by!(name: 'Minibus'),
  attribute_definition: AttributeDefinition.find_by!(name: 'passenger_capacity'),
  is_required: true
)

CategoryAttribute.create!(
  category: Category.find_by!(name: 'Bus'),
  attribute_definition: AttributeDefinition.find_by!(name: 'passenger_capacity'),
  is_required: true
)

CategoryAttribute.create!(
  category: Category.find_by!(name: 'Truck'),
  attribute_definition: AttributeDefinition.find_by!(name: 'load_capacity'),
  is_required: true
)

# Liability Limits
puts "Seeding liability limits..."
LiabilityLimit.create!(
  insurance_type: insurance_type_records['Motor'],
  coverage_type: third_party,
  benefit_type: 'Bodily Injury',
  max_limit: 250_000
)

LiabilityLimit.create!(
  insurance_type: insurance_type_records['Motor'],
  coverage_type: third_party,
  benefit_type: 'Death',
  min_limit: 30_000,
  max_limit: 250_000
)

LiabilityLimit.create!(
  insurance_type: insurance_type_records['Motor'],
  coverage_type: third_party,
  benefit_type: 'Property Damage',
  max_limit: 200_000
)

LiabilityLimit.create!(
  insurance_type: insurance_type_records['Motor'],
  coverage_type: third_party,
  benefit_type: 'Emergency Medical Treatment',
  max_limit: 15_000
)

puts "✅ All seed data loaded successfully!"

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

puts "Seed completed successfully!"

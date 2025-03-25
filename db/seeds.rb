roles = [
  { name: 'admin' },
  { name: 'agent' },
  { name: 'customer' },
  { name: 'manager' }
]

roles.each do |role|
  Role.find_or_create_by!(name: role[:name])
end

# Create permissions
permissions = [
  { name: 'read_policies', resource: 'insurance_policies', action: 'read' },
  { name: 'create_policies', resource: 'insurance_policies', action: 'create' },
  { name: 'update_policies', resource: 'insurance_policies', action: 'update' },
  { name: 'delete_policies', resource: 'insurance_policies', action: 'delete' }
  # Add more permissions as needed
]

permissions.each do |permission|
  Permission.find_or_create_by!(permission)
end

# Add user management permissions
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

# Assign permissions to roles
admin_role = Role.find_by(name: 'admin')
agent_role = Role.find_by(name: 'agent')
customer_role = Role.find_by(name: 'customer')
manager_role = Role.find_by(name: 'manager')

# Admin has all permissions
Permission.all.each do |permission|
  RolePermission.find_or_create_by!(role: admin_role, permission: permission)
end

# Agents can read and create policies
[
  Permission.find_by(name: 'read_policies'),
  Permission.find_by(name: 'create_policies')
].each do |permission|
  RolePermission.find_or_create_by!(role: agent_role, permission: permission)
end

# Customers can only read policies
Permission.find_by(name: 'read_policies').tap do |permission|
  RolePermission.find_or_create_by!(role: customer_role, permission: permission)
end

# Managers can read, create and update policies
[
  Permission.find_by(name: 'read_policies'),
  Permission.find_by(name: 'create_policies'),
  Permission.find_by(name: 'update_policies')
].each do |permission|
  RolePermission.find_or_create_by!(role: manager_role, permission: permission)
end

# Admin gets all user permissions
Permission.where(resource: 'users').each do |permission|
  RolePermission.find_or_create_by!(role: admin_role, permission: permission)
end

# Managers can read and update users
Permission.where(resource: 'users', action: [ 'read', 'update' ]).each do |permission|
  RolePermission.find_or_create_by!(role: manager_role, permission: permission)
end

# Create an admin user
admin = User.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.verified = true
end
admin.roles << admin_role unless admin.roles.include?(admin_role)

# Create a manager user
manager = User.find_or_create_by!(email: 'manager@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.verified = true
end
manager.roles << manager_role unless manager.roles.include?(manager_role)

# Create an agent user
agent = User.find_or_create_by!(email: 'agent@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.verified = true
end
agent.roles << agent_role unless agent.roles.include?(agent_role)

# Create a customer user
customer = User.find_or_create_by!(email: 'customer@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.verified = true
end
customer.roles << customer_role unless customer.roles.include?(customer_role)

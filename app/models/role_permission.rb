class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  validates :role_id, uniqueness: { scope: :permission_id }

  scope :for_role, ->(role) { where(role: role) }
  scope :for_permission, ->(permission) { where(permission: permission) }
  scope :for_resource, ->(resource) { joins(:permission).where(permissions: { resource: resource }) }
  scope :for_action, ->(action) { joins(:permission).where(permissions: { action: action }) }

  def self.grant(role, resource, action)
    permission = Permission.find_or_create_by(resource: resource, action: action)
    create(role: role, permission: permission)
  end

  def self.revoke(role, resource, action)
    permission = Permission.find_by(resource: resource, action: action)
    return false unless permission

    role_permission = find_by(role: role, permission: permission)
    role_permission&.destroy
  end
end

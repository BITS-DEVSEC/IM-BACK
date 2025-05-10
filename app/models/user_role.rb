class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :role_id, uniqueness: { scope: :user_id }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_role, ->(role) { where(role: role) }
  scope :with_role_name, ->(role_name) { joins(:role).where(roles: { name: role_name }) }

  def self.assign_role(user, role)
    find_or_create_by(user: user, role: role)
  end

  def self.remove_role(user, role)
    user_role = find_by(user: user, role: role)
    user_role&.destroy
  end

  def self.user_has_role?(user, role_name)
    with_role_name(role_name).for_user(user).exists?
  end
end

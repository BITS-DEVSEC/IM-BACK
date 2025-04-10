class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :resource, presence: true
  validates :action, presence: true
end

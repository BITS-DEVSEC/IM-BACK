require 'rails_helper'

RSpec.describe RolePermission, type: :model do
  attributes = [
    { role: [ :belong_to ] },
    { permission: [ :belong_to ] },
    { role_id: [ { uniqueness: { scope: :permission_id } } ] }
  ]

  include_examples "model_shared_spec", :role_permission, attributes


  describe 'scopes' do
    before do
      @role = create(:role, name: 'admin')
      @permission1 = create(:permission, resource: 'users', action: 'read')
      @permission2 = create(:permission, resource: 'users', action: 'write')
      @role_permission1 = create(:role_permission, role: @role, permission: @permission1)
      @role_permission2 = create(:role_permission, role: @role, permission: @permission2)
    end

    it 'filters by role' do
      result = RolePermission.for_role(@role)
      expect(result).to include(@role_permission1, @role_permission2)
    end

    it 'filters by permission' do
      result = RolePermission.for_permission(@permission1)
      expect(result).to include(@role_permission1)
      expect(result).not_to include(@role_permission2)
    end

    it 'filters by resource' do
      result = RolePermission.for_resource('users')
      expect(result).to include(@role_permission1, @role_permission2)
    end

    it 'filters by action' do
      result = RolePermission.for_action('read')
      expect(result).to include(@role_permission1)
      expect(result).not_to include(@role_permission2)
    end
  end
end

require 'rails_helper'

RSpec.describe UserRole, type: :model do
  attributes = [
    { user: [ :belong_to ] },
    { role: [ :belong_to ] },
    { role_id: [ { uniqueness: { scope: :user_id } } ] }
  ]

  include_examples "model_shared_spec", :user_role, attributes
  end

  describe 'scopes' do
    before do
      @user = create(:user)
      @admin_role = create(:role, name: 'admin')
      @customer_role = create(:role, name: 'customer')
      @user_role1 = create(:user_role, user: @user, role: @admin_role)
      @user_role2 = create(:user_role, user: @user, role: @customer_role)
    end

    it 'filters by user' do
      result = UserRole.for_user(@user)
      expect(result).to include(@user_role1, @user_role2)
    end

    it 'filters by role' do
      result = UserRole.for_role(@admin_role)
      expect(result).to include(@user_role1)
      expect(result).not_to include(@user_role2)
    end

    it 'filters by role name' do
      result = UserRole.with_role_name('admin')
      expect(result).to include(@user_role1)
      expect(result).not_to include(@user_role2)
    end
  end

  describe 'class methods' do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: 'editor') }

    describe '.assign_role' do
      it 'assigns a role to a user' do
        expect {
          UserRole.assign_role(user, role)
        }.to change(UserRole, :count).by(1)

        user_role = UserRole.last
        expect(user_role.user).to eq(user)
        expect(user_role.role).to eq(role)
      end

      it 'does not create duplicate user_role' do
        UserRole.assign_role(user, role)

        expect {
          UserRole.assign_role(user, role)
        }.not_to change(UserRole, :count)
      end
    end

    describe '.remove_role' do
      it 'removes a role from a user' do
        UserRole.assign_role(user, role)

        expect {
          UserRole.remove_role(user, role)
        }.to change(UserRole, :count).by(-1)
      end

      it 'returns false if user does not have the role' do
        expect(UserRole.remove_role(user, role)).to be_falsey
      end
    end
  end

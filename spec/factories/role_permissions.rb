FactoryBot.define do
  factory :role_permission do
    association :role
    association :permission

    trait :admin_permission do
      association :role, factory: [ :role, :admin ]
    end

    trait :customer_permission do
      association :role, factory: [ :role, :customer ]
    end

    trait :agent_permission do
      association :role, factory: [ :role, :agent ]
    end

    trait :read_permission do
      association :permission, action: 'read'
    end

    trait :write_permission do
      association :permission, action: 'write'
    end

    trait :delete_permission do
      association :permission, action: 'delete'
    end

    trait :users_resource do
      association :permission, resource: 'users'
    end

    trait :policies_resource do
      association :permission, resource: 'policies'
    end

    trait :claims_resource do
      association :permission, resource: 'claims'
    end
  end
end

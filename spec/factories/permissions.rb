FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}" }
    sequence(:resource) { |n| "resource_#{n}" }
    sequence(:action) { |n| "action_#{n}" }

    trait :read do
      action { "read" }
    end

    trait :write do
      action { "write" }
    end

    trait :delete do
      action { "delete" }
    end

    trait :users_resource do
      resource { "users" }
      name { "#{action}_users" }
    end

    trait :policies_resource do
      resource { "policies" }
      name { "#{action}_policies" }
    end

    trait :claims_resource do
      resource { "claims" }
      name { "#{action}_claims" }
    end

    factory :read_users_permission, traits: [ :read, :users_resource ]
    factory :write_users_permission, traits: [ :write, :users_resource ]
    factory :delete_users_permission, traits: [ :delete, :users_resource ]

    factory :read_policies_permission, traits: [ :read, :policies_resource ]
    factory :write_policies_permission, traits: [ :write, :policies_resource ]
    factory :delete_policies_permission, traits: [ :delete, :policies_resource ]
  end
end

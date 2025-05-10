FactoryBot.define do
  factory :user_role do
    association :user
    association :role

    trait :admin do
      association :role, factory: [ :role, :admin ]
    end

    trait :customer do
      association :role, factory: [ :role, :customer ]
    end

    trait :agent do
      association :role, factory: [ :role, :agent ]
    end

    trait :manager do
      association :role, factory: [ :role, :manager ]
    end

    trait :with_verified_user do
      association :user, factory: [ :user, :verified ]
    end

    trait :with_customer_user do
      association :user, factory: [ :user, :with_customer ]
    end
  end
end

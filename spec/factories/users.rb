FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    phone_number { Faker::PhoneNumber.cell_phone }
    fin { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    verified { false }

    trait :verified do
      verified { true }
    end

    trait :with_customer do
      after(:create) do |user|
        create(:customer, user: user)
      end
    end

    trait :with_role do
      transient do
        role_name { 'customer' }
      end

      after(:create) do |user, evaluator|
        role = Role.find_by(name: evaluator.role_name) || create(:role, name: evaluator.role_name)
        create(:user_role, user: user, role: role)
      end
    end

    trait :admin do
      after(:create) do |user|
        role = Role.find_by(name: 'admin') || create(:role, name: 'admin')
        create(:user_role, user: user, role: role)
      end
    end

    trait :customer do
      after(:create) do |user|
        role = Role.find_by(name: 'customer') || create(:role, name: 'customer')
        create(:user_role, user: user, role: role)
      end
    end

    trait :agent do
      after(:create) do |user|
        role = Role.find_by(name: 'agent') || create(:role, name: 'agent')
        create(:user_role, user: user, role: role)
      end
    end

    trait :manager do
      after(:create) do |user|
        role = Role.find_by(name: 'manager') || create(:role, name: 'manager')
        create(:user_role, user: user, role: role)
      end
    end

    trait :with_policies do
      transient do
        policies_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:policy, evaluator.policies_count, user: user)
      end
    end

    trait :with_insured_entities do
      transient do
        entities_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:insured_entity, evaluator.entities_count, user: user)
      end
    end

    trait :email_only do
      phone_number { nil }
      fin { nil }
    end

    trait :phone_only do
      email { nil }
      password { nil }
      password_confirmation { nil }
      fin { nil }
    end

    trait :fin_only do
      email { nil }
      password { nil }
      password_confirmation { nil }
      phone_number { nil }
    end

    trait :with_insurer do
      after(:create) do |user|
        create(:insurer, user: user)
      end
    end

    trait :insurer do
      after(:create) do |user|
        role = Role.find_by(name: 'insurer') || create(:role, name: 'insurer')
        create(:user_role, user: user, role: role)
        create(:insurer, user: user)
      end
    end
  end
end
